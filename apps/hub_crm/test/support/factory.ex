defmodule HubCrm.Factory do
  # with Ecto
  use ExMachina.Ecto, repo: HubCrm.Repo

  def user_factory do
    %HubCrm.Identities.User{
      first_name: "Capirca",
      first_name_kana: "カプリか",
      gender: "famale",
      hub_identity_uid: "hub_identity_uid",
      last_name: "Six",
      last_name_kana: "シくス",
      occupation: "Cylon SuperStar!",
      uuid: Ecto.UUID.generate()
    }
  end

  def address_factory do
    %HubCrm.Identities.Address{
      address_1: "3-7-27 51Fl",
      address_2: "Hiyoshi",
      address_3: "Kohoku Ku",
      address_4: "Yokohama Shi",
      address_5: "Kanagawa Ken",
      country: "JPN",
      default: true,
      postal_code: "223-0061",
      uuid: Ecto.UUID.generate(),
      user: build(:user)
    }
  end

  def japanese_address_factory do
    %HubCrm.Identities.Address{
      address_1: "3-7-27 51Fl",
      address_2: "Hiyoshi",
      address_3: "Kohoku Ku",
      address_4: "Yokohama Shi",
      address_5: "Kanagawa Ken",
      country: "JPN",
      default: true,
      postal_code: "223-0061",
      uuid: Ecto.UUID.generate(),
      user: build(:user)
    }
  end

  def thai_address_factory do
    %HubCrm.Identities.Address{
      address_1: "59 19 ซอย แขวง ลาดพร้าว",
      address_2: "เขตลาดพร้าว",
      address_3: "กรุงเทพมหานคร",
      country: "THA",
      default: false,
      postal_code: "10230",
      uuid: Ecto.UUID.generate(),
      user: build(:user)
    }
  end

  def usa_address_factory do
    %HubCrm.Identities.Address{
      address_1: "1 Lake Ave",
      address_2: "Colorado Springs",
      address_3: "CO",
      country: "USA",
      default: false,
      postal_code: "80906",
      uuid: Ecto.UUID.generate(),
      user: build(:user)
    }
  end
end
