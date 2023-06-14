{ provider, self' }:

{
  options = {
    provider.${provider} = self'.legacyPackages.lib.mkProviderAttrs provider;
    resource = self'.legacyPackages.lib.mkResourceAttrs provider;
    data = self'.legacyPackages.lib.mkDataAttrs provider;
  };
}
