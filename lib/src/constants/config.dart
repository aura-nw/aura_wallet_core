sealed class AuraNetWorkConfig {
  static Map<String, dynamic> devConfig = {
    'CHAIN_INFO': {
      "bech32Config": "aura",
      "chainId": "serenity-testnet-001",
      "coin": {
        "denom": "utaura",
        "decimal": 6,
      }
    },
    'NET_WORK_INFO': {
      "baseUrl": "https://indexer-v2.dev.aurascan.io/api/v2/graphql",
      "lcdHost": "https://lcd.dev.aura.network",
      "grpcHost": "https://grpc.dev.aura.network",
      "grpcPort": 443,
    },
  };

  static Map<String, dynamic> testNetConfig = {
    'CHAIN_INFO': {
      "bech32Config": "aura",
      "chainId": "serenity-testnet-001",
      "coin": {
        "denom": "uaura",
        "decimal": 6,
      },
    },
    'NET_WORK_INFO': {
      "baseUrl": "https://indexer-v2.dev.aurascan.io/api/v2/graphql",
      "lcdHost": "https://lcd.serenity.aura.network",
      "grpcHost": "http://grpc.serenity.aura.network",
      "grpcPort": 9092,
    },
  };

  static Map<String, dynamic> euphoriaConfig = {
    'CHAIN_INFO': {
      "bech32Config": "aura",
      "chainId": "euphoria-2",
      "coin": {
        "denom": "ueaura",
        "decimal": 6,
      },
    },
    'NET_WORK_INFO': {
      "baseUrl": "https://indexer-v2.staging.aurascan.io/api/v2/graphql",
      "lcdHost": "https://lcd.euphoria.aura.network",
      "grpcHost": "http://grpc.euphoria.aura.network",
      "grpcPort": 9090,
    },
  };

  static Map<String, dynamic> mainNetConfig = {
    'CHAIN_INFO': {
      "bech32Config": "aura",
      "chainId": "xstaxy-1",
      "coin": {
        "denom": "uaura",
        "decimal": 6,
      },
    },
    'NET_WORK_INFO': {
      "baseUrl": "https://horoscope.aura.network/api/v2/graphql",
      "lcdHost": "https://lcd.aura.network",
      "grpcHost": "https://grpc.aura.network",
      "grpcPort": 9090,
    },
  };
}
