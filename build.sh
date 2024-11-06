docker run -v $(pwd)/TinfoilWebServer:/tinfoil -w /tinfoil -it mcr.microsoft.com/dotnet/sdk:8.0 bash -c 'dotnet publish TinfoilWebServer.csproj --self-contained true -c Release -r linux-x64 -p:PublishSingleFile=true -p:IncludeNativeLibrariesForSelfExtract=true -o Publish && chown -R '$(id -ur)' Publish'

cat<<EOF>TinfoilWebServer/Publish/TinfoilWebServer.config.json
﻿{
  "ServedDirectories": [ "/tinfoil/packages/nsp", "/tinfoil/packages/nsz", "/tinfoil/packages/xsi", "/tinfoil/packages/xcz" ],
  "StripDirectoryNames": true,
  "ServeEmptyDirectories": false,
  "AllowedExt": [ "nsp", "nsz", "xci", "xcz" ],
  "MessageOfTheDay": "Hello World!",
  "CustomIndexPath": null,
  "Cache": {
    "AutoDetectChanges": true,
    "PeriodicRefreshDelay": "01:00:00"
  },
  "Authentication": {
    "Enabled": true,
    "WebBrowserAuthEnabled": false,
    "PwdType": "Sha256",
    "Users": [
      {
        "Name": "dina",
        "Pwd": "123456",
        "MaxFingerprints": 1,
        "MessageOfTheDay": "Hello Dina!",
        "CustomIndexPath": null
      }
    ]
  },
  "FingerprintsFilter": {
    "Enabled": true,
    "FingerprintsFilePath": "fingerprints.json",
    "MaxFingerprints": 1
  },
  "Blacklist": {
    "Enabled": true,
    "FilePath": "blacklist.txt",
    "MaxConsecutiveFailedAuth": 3,
    "IsBehindProxy": false
  },
  "Kestrel": {
    "Endpoints": {
      "Http": {
        "Url": "http://0.0.0.0:80"
      }
    }
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    },
    "Console": {
      "LogLevel": {
        "Default": "Information"
      }
    },
    "File": {
      "Path": "TinfoilWebServer.log",
      "Append": true,
      "MinLevel": "Information",
      "FileSizeLimitBytes": 1000000,
      "MaxRollingFiles": 10
    }
  }
}
EOF

cat<<EOF>Dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /tinfoil
RUN mkdir -p /tinfoil/packages/nsp /tinfoil/packages/nsz /tinfoil/packages/xsi /tinfoil/packages/xcz
COPY TinfoilWebServer .
COPY TinfoilWebServer.config.json .
ENTRYPOINT ./TinfoilWebServer
EOF

docker build -t tinfoil -f Dockerfile TinfoilWebServer/Publish


docker run -p8083:80 -v '/home/sergey/YuzuGames/New Super Mario Bros U Deluxe [NSZ]/':/tinfoil/packages/nsp -it tinfoil

