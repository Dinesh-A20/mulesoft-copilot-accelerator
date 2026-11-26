param(
    [string]$JavaHome = $env:JAVA_HOME,
    [switch]$AddMissingLaunches
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$projectRoot = Split-Path -Parent $PSScriptRoot
$testResources = Join-Path $projectRoot 'src\test\resources'
$fixtureDirectory = Join-Path $testResources 'munit-local'
$testRenderer = Join-Path $testResources 'renderer\renderer.jar'
$toolDirectory = Join-Path $projectRoot '.tools'
$secureTool = Join-Path $toolDirectory 'secure-properties-tool-j17.jar'

$suiteNames = @(
    'main-flow-test-suite',
    'account-generate-document-flow-test-suite',
    'common-validation-subflows-test-suite',
    'mq-publish-business-event-flow-test-suite',
    'opportunity-export-flow-test-suite',
    'opportunity-export-disabled-test-suite'
)

if ($AddMissingLaunches) {
    $baseLaunch = Join-Path $projectRoot 'MUnit Local - main-flow-test-suite.launch'
    if (-not (Test-Path -LiteralPath $baseLaunch)) {
        throw 'Generate the complete local fixture set first; the base MUnit Local launch is missing.'
    }
    foreach ($suite in $suiteNames) {
        $destination = Join-Path $projectRoot "MUnit Local - $suite.launch"
        if (Test-Path -LiteralPath $destination) { continue }
        [xml]$launch = Get-Content -LiteralPath $baseLaunch -Raw
        $resources = $launch.launchConfiguration.setAttribute | Where-Object { $_.key -eq 'test_resources' }
        $resources.RemoveAll()
        $resources.SetAttribute('key', 'test_resources')
        $entry = $launch.CreateElement('setEntry')
        $entry.SetAttribute('value', "$suite.xml")
        [void]$resources.AppendChild($entry)
        if ($suite -eq 'opportunity-export-flow-test-suite') {
            $environment = $launch.launchConfiguration.mapAttribute | Where-Object { $_.key -eq 'org.eclipse.debug.core.environmentVariables' }
            ($environment.mapEntry | Where-Object { $_.key -eq 'mule.env' }).SetAttribute('value', 'local')
        }
        if ($suite -eq 'opportunity-export-disabled-test-suite') {
            $environment = $launch.launchConfiguration.mapAttribute | Where-Object { $_.key -eq 'org.eclipse.debug.core.environmentVariables' }
            foreach ($setting in @(@('etl.enabled', 'true'), @('etl.initial-state', 'started'))) {
                $entry = $launch.CreateElement('mapEntry')
                $entry.SetAttribute('key', $setting[0])
                $entry.SetAttribute('value', $setting[1])
                [void]$environment.AppendChild($entry)
            }
        }
        $launch.Save($destination)
        Write-Output "Added Studio MUnit configuration: $suite"
    }
    return
}

if (-not $JavaHome) {
    $studioPlugins = 'C:\AnypointStudio\plugins'
    if (Test-Path -LiteralPath $studioPlugins) {
        $studioJdk = Get-ChildItem -LiteralPath $studioPlugins -Directory -Filter 'org.mule.tooling.jdk.v17.win32.x86_64_*' | Select-Object -First 1
        if ($studioJdk) { $JavaHome = $studioJdk.FullName }
    }
}
if (-not $JavaHome) {
    $extensions = Join-Path $env:USERPROFILE '.vscode\extensions'
    if (Test-Path -LiteralPath $extensions) {
        $dependencyExtension = Get-ChildItem -LiteralPath $extensions -Directory -Filter 'salesforce.mule-dx-dependencies-*' | Select-Object -First 1
        if ($dependencyExtension) {
            $jdk = Get-ChildItem -LiteralPath (Join-Path $dependencyExtension.FullName 'build\deps') -Directory -Filter 'jdk-17*' | Select-Object -First 1
            if ($jdk) { $JavaHome = $jdk.FullName }
        }
    }
}
if (-not $JavaHome) {
    throw 'JDK 17 was not found. Set JAVA_HOME to a JDK 17 installation and rerun setup.'
}
$java = Join-Path $JavaHome 'bin\java.exe'
$keytool = Join-Path $JavaHome 'bin\keytool.exe'
if (-not (Test-Path -LiteralPath $java) -or -not (Test-Path -LiteralPath $keytool)) {
    throw 'JAVA_HOME must point to a JDK 17 installation containing java and keytool.'
}
$javaVersion = & $java --version
if ($LASTEXITCODE -ne 0 -or $javaVersion[0] -notmatch '^(openjdk|java) 17([.+ ]|$)') {
    throw 'The local MUnit fixtures require JDK 17. Set JAVA_HOME to JDK 17 and rerun setup.'
}
if (-not (Test-Path -LiteralPath $secureTool)) {
    throw "Missing MuleSoft Secure Properties Tool: $secureTool. Download the Java 17 tool from the MuleSoft secure configuration properties documentation."
}

$destinations = @($fixtureDirectory, $testRenderer) + @($suiteNames | ForEach-Object { Join-Path $projectRoot "MUnit Local - $($_).launch" })
foreach ($destination in $destinations) {
    if (Test-Path -LiteralPath $destination) {
        throw "Refusing to overwrite an existing test fixture: $destination"
    }
}

[xml]$classpath = Get-Content -LiteralPath (Join-Path $projectRoot '.classpath') -Raw
$runtimeEntry = @($classpath.classpath.classpathentry | Where-Object { $_.path -like 'MULE_RUNTIME/*' } | Select-Object -First 1)
if ($runtimeEntry.Count -ne 1) {
    throw 'Select a Mule runtime for this project in Anypoint Studio before generating its test launch configurations.'
}
$runtimeId = $runtimeEntry[0].path.Substring('MULE_RUNTIME/'.Length)

$rendererCandidates = @(
    (Join-Path $projectRoot 'renderer\target\account-pdf-renderer-1.0.0-standalone.jar'),
    (Join-Path $env:USERPROFILE '.m2\repository\com\enterprise\integrations\account-pdf-renderer\1.0.0\account-pdf-renderer-1.0.0-standalone.jar')
)
$renderer = $rendererCandidates | Where-Object { Test-Path -LiteralPath $_ } | Select-Object -First 1
if (-not $renderer) {
    throw 'The packaged standalone PDF renderer is missing. Build the renderer module before setting up Studio MUnit.'
}

function New-TestValue([int]$bytes) {
    $data = New-Object byte[] $bytes
    $random = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try { $random.GetBytes($data) } finally { $random.Dispose() }
    return -join ($data | ForEach-Object { $_.ToString('x2') })
}

function Invoke-Tool([string]$executable, [string[]]$arguments) {
    & $executable @arguments
    if ($LASTEXITCODE -ne 0) { throw "Local test fixture generation failed: $executable" }
}

function Write-Utf8([string]$path, [string]$content) {
    [System.IO.File]::WriteAllText($path, $content, (New-Object System.Text.UTF8Encoding($false)))
}

New-Item -ItemType Directory -Force -Path $toolDirectory | Out-Null
$staging = Join-Path $toolDirectory ("munit-setup-" + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $staging | Out-Null
try {
    $storePassword = New-TestValue 16
    $encryptionKey = New-TestValue 8
    $consumerKey = New-TestValue 16
    $clientId = New-TestValue 16
    $clientSecret = New-TestValue 16
    $serverStore = Join-Path $staging 'server.p12'
    $certificate = Join-Path $staging 'localhost.cer'
    $trustStore = Join-Path $staging 'truststore.p12'
    $plainProperties = Join-Path $staging 'plain.properties'
    $encryptedProperties = Join-Path $staging 'secure.properties'

    Invoke-Tool $keytool @('-genkeypair', '-alias', 'munit-local', '-keyalg', 'RSA', '-keysize', '2048', '-validity', '365', '-dname', 'CN=localhost', '-ext', 'SAN=dns:localhost,ip:127.0.0.1', '-storetype', 'PKCS12', '-keystore', $serverStore, '-storepass', $storePassword, '-keypass', $storePassword, '-noprompt')
    Invoke-Tool $keytool @('-exportcert', '-alias', 'munit-local', '-keystore', $serverStore, '-storepass', $storePassword, '-file', $certificate)
    Invoke-Tool $keytool @('-importcert', '-alias', 'munit-local', '-storetype', 'PKCS12', '-keystore', $trustStore, '-storepass', $storePassword, '-file', $certificate, '-noprompt')

    Write-Utf8 $plainProperties @"
http.secure.key-password=$storePassword
http.secure.store-password=$storePassword
salesforce.secure.consumer-key=$consumerKey
salesforce.secure.principal=munit@example.invalid
salesforce.secure.store-password=$storePassword
mq.secure.client-id=$clientId
mq.secure.client-secret=$clientSecret
"@
    Invoke-Tool $java @('-cp', $secureTool, 'com.mulesoft.tools.SecurePropertiesTool', 'file', 'encrypt', 'AES', 'CBC', $encryptionKey, $plainProperties, $encryptedProperties)

    $socket = New-Object System.Net.Sockets.TcpListener([System.Net.IPAddress]::Loopback, 0)
    $socket.Start()
    try { $port = $socket.LocalEndpoint.Port } finally { $socket.Stop() }

    foreach ($suite in $suiteNames) {
        $testEnvironment = if ($suite -eq 'opportunity-export-flow-test-suite') { 'local' } else { 'dev' }
        $guardTestOverrides = if ($suite -eq 'opportunity-export-disabled-test-suite') {
            '<mapEntry key="etl.enabled" value="true"/><mapEntry key="etl.initial-state" value="started"/>'
        } else { '' }
        Write-Utf8 (Join-Path $staging "$suite.launch") @"
<?xml version="1.0" encoding="UTF-8"?>
<launchConfiguration type="org.eclipse.jdt.munit.launchconfig">
  <stringAttribute key="launch_mule_server_version" value="$runtimeId"/>
  <listAttribute key="mule-project-names"><listEntry value="salesforce-pdf-api"/></listAttribute>
  <booleanAttribute key="munit_run" value="true"/>
  <stringAttribute key="org.eclipse.jdt.launching.PROJECT_ATTR" value="salesforce-pdf-api"/>
  <mapAttribute key="org.eclipse.debug.core.environmentVariables">
    <mapEntry key="mule.env" value="$testEnvironment"/>
    <mapEntry key="secure.key" value="$encryptionKey"/>
    <mapEntry key="secure.file" value="munit-local/secure.properties"/>
    <mapEntry key="api.id" value="1234567"/>
    <mapEntry key="test.truststore" value="munit-local/truststore.p12"/>
    <mapEntry key="test.store-password" value="$storePassword"/>
    <mapEntry key="http.host" value="127.0.0.1"/>
    <mapEntry key="http.port" value="$port"/>
    <mapEntry key="http.tls.alias" value="munit-local"/>
    <mapEntry key="http.tls.keystore" value="munit-local/server.p12"/>
    <mapEntry key="salesforce.keystore" value="munit-local/server.p12"/>
    <mapEntry key="salesforce.certificate-alias" value="munit-local"/>
    <mapEntry key="salesforce.token-endpoint" value="https://salesforce.invalid/services/oauth2/token"/>
    <mapEntry key="salesforce.audience" value="https://salesforce.invalid"/>
    <mapEntry key="mq.url" value="https://mq.invalid"/>
    $guardTestOverrides
  </mapAttribute>
  <booleanAttribute key="run_coverage" value="true"/>
  <setAttribute key="test_names"/>
  <setAttribute key="test_resources"><setEntry value="$suite.xml"/></setAttribute>
</launchConfiguration>
"@
    }
    New-Item -ItemType Directory -Path $fixtureDirectory | Out-Null
    Copy-Item -LiteralPath $serverStore, $trustStore, $encryptedProperties -Destination $fixtureDirectory
    New-Item -ItemType Directory -Force -Path (Split-Path -Parent $testRenderer) | Out-Null
    Copy-Item -LiteralPath $renderer -Destination $testRenderer
    foreach ($suite in $suiteNames) {
        Copy-Item -LiteralPath (Join-Path $staging "$suite.launch") -Destination (Join-Path $projectRoot "MUnit Local - $suite.launch")
    }
    Write-Output 'Studio MUnit fixtures and run configurations generated. Refresh the project in Studio.'
} finally {
    if (Test-Path -LiteralPath $staging) {
        Remove-Item -LiteralPath $staging -Recurse -Force
    }
}
