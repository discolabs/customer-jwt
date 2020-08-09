defmodule CustomerJwt.Token do
  use Joken.Config

  @validity_in_seconds 60
  @shared_secret Application.get_env(:customer_jwt, :shared_secret)

  def generate_and_sign_for_customer(customer_id, shopify_domain, current_time) do
    claims = get_customer_claims(customer_id, shopify_domain, current_time)
    signer = get_shopify_domain_signer(shopify_domain)
    generate_and_sign(claims, signer)
  end

  def token_config do
    default_claims(aud: "*")
  end

  defp get_customer_claims(customer_id, shopify_domain, current_time) do
    %{
      "iss" => "https://#{shopify_domain}/admin",
      "dest" => "https://#{shopify_domain}",
      "sub" => customer_id,
      "nbf" => current_time,
      "iat" => current_time,
      "exp" => current_time + @validity_in_seconds
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
