if([System.IO.File]::Exists("build.zip")) {
    [System.IO.File]::Delete("build.zip");
}

Add-Type -AssemblyName System.IO.Compression.FileSystem

$archive = [System.IO.Compression.ZipFile]::Open("$pwd\build.zip", 'Create');

Get-ChildItem -Recurse -Filter *.lua | ForEach-Object {
    $entryPath = $_.FullName -replace ([regex]::Escape($PWD.ProviderPath) + '[/\\]')
    $null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
      $archive, 
      $_.FullName, 
      [System.IO.Path]::Combine("bin\x64\plugins\cyber_engine_tweaks\mods\menu_mod", $entryPath)
    )
  };

$null = [System.IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
      $archive, 
      "LICENSE", 
      [System.IO.Path]::Combine("bin\x64\plugins\cyber_engine_tweaks\mods\menu_mod", "LICENSE")
);

$archive.Dispose();

"Build complete" | Write-Host;
