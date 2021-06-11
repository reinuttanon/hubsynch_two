defmodule HubIdentity.Identities.EmailTest do
  use HubIdentity.DataCase

  alias HubIdentity.Identities.Email

  import HubIdentity.Factory

  describe "confirmed_changeset/1" do
    setup do
      five_seconds_ago =
        NaiveDateTime.utc_now()
        |> NaiveDateTime.add(-5, :second)
        |> NaiveDateTime.truncate(:second)

      user = insert(:user)

      %{five_seconds_ago: five_seconds_ago, user: user}
    end

    test "returns a valid address returns a valid changeset with confirmed_at set", %{
      five_seconds_ago: five_seconds_ago,
      user: user
    } do
      confirmed_changeset =
        Email.confirmed_changeset(%Email{}, %{address: "erin@hivelocity.co.jp", user_id: user.id})

      assert confirmed_changeset.valid?
      assert confirmed_changeset.changes.user_id == user.id
      assert confirmed_changeset.changes[:primary] == nil
      assert confirmed_changeset.changes.confirmed_at != nil
      assert confirmed_changeset.changes.uid != nil

      assert :gt ==
               NaiveDateTime.compare(confirmed_changeset.changes.confirmed_at, five_seconds_ago)
    end

    test "returns error if address not present" do
      changeset = Email.confirmed_changeset(%Email{}, %{})
      assert changeset.errors[:address] == {"can't be blank", [validation: :required]}

      changeset = Email.confirmed_changeset(%Email{}, %{address: nil})
      assert changeset.errors[:address] == {"can't be blank", [validation: :required]}

      changeset = Email.confirmed_changeset(%Email{}, %{address: ""})
      assert changeset.errors[:address] == {"can't be blank", [validation: :required]}
    end

    test "returns error for invalid address format" do
      invalids = ["no_at_sign", "@no_beginning", "this @space.com"]

      for invalid <- invalids do
        changeset = Email.confirmed_changeset(%Email{}, %{address: invalid})

        assert changeset.errors[:address] ==
                 {"must have the @ sign and no spaces", [validation: :format]},
               invalid
      end
    end

    test "reutrns error for invalid address length" do
      stupid_long =
        "FH276J7FFYZULTM3362CCYYQ6PQR7FK99W63TXZMMME2WHU6ZZW2GG39LP72DU6EUENWNLEJRHPR@CEHXWJZWPFXPMGDDZ9C2WR3RM6UUUMTRQJZLMRTG2GHJ23JYNNWF2WHTXW6HKCZDWVLXQLC2EKGMF9QQ.com"

      changeset = Email.confirmed_changeset(%Email{}, %{address: stupid_long})

      assert changeset.errors[:address] ==
               {"should be at most %{count} character(s)",
                [{:count, 160}, {:validation, :length}, {:kind, :max}, {:type, :string}]}
    end

    test "returns error for non-unique address" do
      email = insert(:email)
      changeset = Email.confirmed_changeset(%Email{}, %{address: email.address})

      assert changeset.errors[:address] ==
               {"has already been taken", [{:validation, :unsafe_unique}, {:fields, [:address]}]}
    end

    test "returns error if no user_id" do
      changeset = Email.confirmed_changeset(%Email{}, %{address: "erin@hivelocity.co.jp"})
      assert changeset.errors[:user_id] == {"can't be blank", [validation: :required]}
    end
  end

  describe "primary_changeset" do
    test "updates the primary to true for a Email record" do
      email = insert(:email, primary: false, confirmed_at: DateTime.utc_now())
      refute email.primary
      assert email.confirmed_at != nil

      primary_changeset = Email.primary_changeset(email, %{primary: true})

      assert primary_changeset.changes.primary
    end

    test "returns an error if the confirmed_at is nil" do
      email = insert(:email, primary: false)
      assert email.confirmed_at == nil

      changeset = Email.primary_changeset(email, %{primary: true})

      refute changeset.valid?
      assert changeset.errors[:confirmation] == {"email must be confirmed", []}
    end
  end
end
