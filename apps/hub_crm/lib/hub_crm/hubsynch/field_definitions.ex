defmodule HubCrm.Hubsynch.FieldDefinitions do
  @moduledoc false
  def get_value(field, key) when is_atom(field) and is_binary(key) do
    with values when is_map(values) <- apply(__MODULE__, field, []),
         value when is_binary(value) <- Map.get(values, key) do
      value
    else
      _ -> ""
    end
  end

  def get_value(field, key) when is_binary(field) do
    String.to_existing_atom(field)
    |> get_value(key)
  end

  def get_value(field, key) when is_integer(key) do
    get_value(field, Integer.to_string(key))
  end

  def get_value(_, _), do: ""

  def get_country("0"), do: "JPN"

  def get_country("1"), do: "JPN"

  def get_country(code) when is_integer(code) do
    Integer.to_string(code)
    |> get_country()
  end

  def get_country(_), do: "UNK"

  def address_1 do
    %{
      "1" => "北海道",
      "2" => "青森県",
      "3" => "岩手県",
      "4" => "宮城県",
      "5" => "秋田県",
      "6" => "山形県",
      "7" => "福島県",
      "8" => "茨城県",
      "9" => "栃木県",
      "10" => "群馬県",
      "11" => "埼玉県",
      "12" => "千葉県",
      "13" => "東京都",
      "14" => "神奈川県",
      "15" => "新潟県",
      "16" => "富山県",
      "17" => "石川県",
      "18" => "福井県",
      "19" => "山梨県",
      "20" => "長野県",
      "21" => "岐阜県",
      "22" => "静岡県",
      "23" => "愛知県",
      "24" => "三重県",
      "25" => "滋賀県",
      "26" => "京都府",
      "27" => "大阪府",
      "28" => "兵庫県",
      "29" => "奈良県",
      "30" => "和歌山県",
      "31" => "鳥取県",
      "32" => "島根県",
      "33" => "岡山県",
      "34" => "広島県",
      "35" => "山口県",
      "36" => "徳島県",
      "37" => "香川県",
      "38" => "愛媛県",
      "39" => "高知県",
      "40" => "福岡県",
      "41" => "佐賀県",
      "42" => "長崎県",
      "43" => "熊本県",
      "44" => "大分県",
      "45" => "宮崎県",
      "46" => "鹿児島県",
      "47" => "沖縄県"
    }
  end

  def blood do
    %{
      "1" => "A",
      "2" => "B",
      "3" => "O",
      "4" => "AB",
      "5" => "unknown"
    }
  end

  def gender do
    %{
      "1" => "male",
      "2" => "female",
      "3" => "other"
    }
  end

  def occupation do
    %{
      "10" => "公務員",
      "20" => "コンサルタント",
      "30" => "コンピューター関連技術職",
      "40" => "コンピューター関連以外の技術職",
      "50" => "金融関係",
      "60" => "医師",
      "70" => "弁護士",
      "80" => "総務・人事・事務",
      "90" => "営業・販売",
      "100" => "研究・開発",
      "110" => "広報・宣伝",
      "120" => "企画・マーケティング",
      "130" => "デザイン関係",
      "140" => "会社経営・役員",
      "150" => "出版・マスコミ関係",
      "160" => "学生・フリーター",
      "170" => "主婦",
      "180" => "その他",
      "999" => "不明"
    }
  end
end
