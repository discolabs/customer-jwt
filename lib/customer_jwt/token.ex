defmodule CustomerJwt.Token do
  use Joken.Config

  @validity_in_seconds Application.get_env(:customer_jwt, :validity_in_seconds)
  @shared_secret Application.get_env(:customer_jwt, :shared_secret)
  @jti_generator Application.get_env(:customer_jwt, :jti_generator, Joken)

  def generate_and_sign_for_customer(customer_id, shopify_domain) do
    claims = get_customer_claims(customer_id, shopify_domain)
    signer = get_shopify_domain_signer(shopify_domain)
    generate_and_sign(claims, signer)
  end

  def token_config do
    default_claims(aud: "*", generate_jti: (&@jti_generator.generate_jti/0))
  end

  defp get_customer_claims(customer_id, shopify_domain) do
    current_time = @jti_generator.current_time()
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
