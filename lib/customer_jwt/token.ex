defmodule CustomerJwt.Token do
  use Joken.Config

  @shared_secret Application.get_env(:customer_jwt, :shared_secret)

  def generate_and_sign_for_customer(customer_id, shopify_domain) do
    claims = get_customer_claims(customer_id, shopify_domain)
    signer = get_shopify_domain_signer(shopify_domain)
    generate_and_sign(claims, signer)
  end

  def token_config do
    default_claims(default_exp: 60, aud: "*")
  end

  defp get_customer_claims(customer_id, shopify_domain) do
    %{
      "iss" => "https://#{shopify_domain}/admin",
      "dest" => "https://#{shopify_domain}",
      "sub" => customer_id
    }
  end

  defp get_shopify_domain_signer(shopify_domain) do
    Joken.Signer.create("HS256", get_shopify_domain_secret(shopify_domain))
  end

  defp get_shopify_domain_secret(shopify_domain) do
    :crypto.hmac(:sha256, @shared_secret, shopify_domain)
    |> Base.encode16()
    |> String.downcase()
  end
end
