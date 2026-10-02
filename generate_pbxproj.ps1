# PowerShell script to generate project.pbxproj for CalorieTracker iOS app
# Run: powershell -ExecutionPolicy Bypass -File generate_pbxproj.ps1

$BaseDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$SourcesDir = Join-Path $BaseDir "CalorieTracker"
$ProjectDir = Join-Path $BaseDir "CalorieTracker.xcodeproj"

if (-not (Test-Path $ProjectDir)) {
    New-Item -ItemType Directory -Path $ProjectDir | Out-Null
}

function New-PbxId {
    return ([guid]::NewGuid().Guid -replace '-', '').Substring(0, 24).ToUpper()
}

# Collect all source files
$SourceFiles = @()
$ResourceFiles = @()

Get-ChildItem -Path $SourcesDir -Recurse -File | ForEach-Object {
    $rel = $_.FullName.Substring($BaseDir.Length + 1)
    $ext = $_.Extension
    if ($ext -eq ".swift") {
        $SourceFiles += $rel
    }
    if ($ext -eq ".plist" -or $ext -eq ".storyboard" -or $ext -eq ".xcassets") {
        $ResourceFiles += $rel
    }
}

# Also add Info.plist
$ResourceFiles += "CalorieTracker/Info.plist"

# Generate IDs
$FileRefs = @{}
$BuildFiles = @{}
$Groups = @{}

foreach ($f in $SourceFiles) {
    $id = New-PbxId
    $FileRefs[$f] = $id
    $id2 = New-PbxId
    $BuildFiles[$f] = $id2
}

foreach ($f in $ResourceFiles) {
    if (-not $FileRefs.ContainsKey($f)) {
        $id = New-PbxId
        $FileRefs[$f] = $id
        $id2 = New-PbxId
        $BuildFiles[$f] = $id2
    }
}

$ProductId = New-PbxId
$ProjectId = New-PbxId
$RootGroupId = New-PbxId
$SourcesBuildPhase = New-PbxId
$FrameworksBuildPhase = New-PbxId
$ResourcesBuildPhase = New-PbxId
$TargetId = New-PbxId
$TargetConfigList = New-PbxId
$ProjectConfigList = New-PbxId
$DebugConfig = New-PbxId
$ReleaseConfig = New-PbxId
$ProjectDebugConfig = New-PbxId
$ProjectReleaseConfig = New-PbxId

$Groups["Models"] = New-PbxId
$Groups["ViewModels"] = New-PbxId
$Groups["Services"] = New-PbxId
$Groups["Data"] = New-PbxId
$Groups["Views"] = New-PbxId
$Groups["Utils"] = New-PbxId
$Groups["Views_Sub_Dashboard"] = New-PbxId
$Groups["Views_Sub_Diary"] = New-PbxId
$Groups["Views_Sub_Camera"] = New-PbxId
$Groups["Views_Sub_Insights"] = New-PbxId
$Groups["Views_Sub_Profile"] = New-PbxId
$Groups["Utils_Sub_Extensions"] = New-PbxId
$Groups["Utils_Sub_Enums"] = New-PbxId
$Groups["Utils_Sub_Constants"] = New-PbxId
$Groups["Utils_Sub_Protocols"] = New-PbxId
$Groups["Utils_Sub_Config"] = New-PbxId
$Groups["Utils_Sub_Debug"] = New-PbxId

$lines = @()
$lines += '// !$*UTF8*!$'
$lines += '{'
$lines += "`tarchiveVersion = 1;"
$lines += "`	tlasses = {"
$lines += "`	};"
$lines += "`	objectVersion = 56;"
$lines += "`	tobjects = {"

# PBXFileReference
$lines += "`n`t`t/* === PBXFileReference === */"
foreach ($k in $FileRefs.Keys | Sort-Object) {
    $name = Split-Path -Leaf $k
    $ext = [System.IO.Path]::GetExtension($k)
    $ft = "sourcecode.swift"
    if ($k -like "*.plist") { $ft = "text.plist.xml" }
    if ($k -like "*.storyboard") { $ft = "file.storyboard" }
    if ($k -like "*.xcassets") { $ft = "folder.assetcatalog" }
    $lines += "`t`t$($FileRefs[$k]) /* $name */ = {isa = PBXFileReference; lastKnownFileType = $ft; path = `"$k`"; sourceTree = `"<group>`";};"
}

$lines += "`t`t$ProductId /* CalorieTracker.app */ = {isa = PBXFileReference; explicitFileType = `"iphoneos.application`"; includeInIndex = 0; path = `"CalorieTracker.app`"; sourceTree = `"BUILT_PRODUCTS_DIR`";};"

# PBXGroup (Root)
$lines += "`n`t`t/* === PBXGroup === */"
$lines += "`t`t$RootGroupId /* CalorieTracker */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$lines += "`t`t`t`t$($Groups['Models']) /* Models */,"
$lines += "`t`t`t`t$($Groups['ViewModels']) /* ViewModels */,"
$lines += "`t`t`t`t$($Groups['Services']) /* Services */,"
$lines += "`t`t`t`t$($Groups['Data']) /* Data */,"
$lines += "`t`t`t`t$($Groups['Views']) /* Views */,"
$lines += "`t`t`t`t$($Groups['Utils']) /* Utils */,"
$lines += "`t`t`t`t$ProductId /* CalorieTracker.app */,"
$lines += "`t`t`t);"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Model group
$lines += "`t`t$($Groups['Models']) /* Models */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$modelFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/Models/*" } | Sort-Object
foreach ($f in $modelFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/Models;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# ViewModel group
$lines += "`t`t$($Groups['ViewModels']) /* ViewModels */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$vmFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/ViewModels/*" } | Sort-Object
foreach ($f in $vmFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/ViewModels;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Services group
$lines += "`t`t$($Groups['Services']) /* Services */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$serviceFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/Services/*" } | Sort-Object
foreach ($f in $serviceFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/Services;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Data group
$lines += "`t`t$($Groups['Data']) /* Data */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$dataFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/Data/*" } | Sort-Object
foreach ($f in $dataFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/Data;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Views group (with subgroups)
$lines += "`t`t$($Groups['Views']) /* Views */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$lines += "`t`t`t`t$($Groups['Views_Sub_Dashboard']) /* Dashboard */,"
$lines += "`t`t`t`t$($Groups['Views_Sub_Diary']) /* Diary */,"
$lines += "`t`t`t`t$($Groups['Views_Sub_Camera']) /* Camera */,"
$lines += "`t`t`t`t$($Groups['Views_Sub_Insights']) /* Insights */,"
$lines += "`t`t`t`t$($Groups['Views_Sub_Profile']) /* Profile */,"
# Views root files
$viewRootFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/Views/*" -and (Split-Path -Parent $_) -eq "CalorieTracker/Views" } | Sort-Object
foreach ($f in $viewRootFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/Views;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Views subgroups
@"
$($Groups['Views_Sub_Dashboard'])|Dashboard|CalorieTracker/Views/Dashboard
$($Groups['Views_Sub_Diary'])|Diary|CalorieTracker/Views/Diary
$($Groups['Views_Sub_Camera'])|Camera|CalorieTracker/Views/Camera
$($Groups['Views_Sub_Insights'])|Insights|CalorieTracker/Views/Insights
$($Groups['Views_Sub_Profile'])|Profile|CalorieTracker/Views/Profile
"@ | ForEach-Object {
    $parts = $_ -split '\|'
    $gid = $parts[0]
    $gname = $parts[1]
    $gpath = $parts[2]
    $lines += "`t`t$gid /* $gname */ = {"
    $lines += "`t`t`tisa = PBXGroup;"
    $lines += "`t`t`tchildren = ("
    $subFiles = $FileRefs.Keys | Where-Object { $_ -like "$gpath/*" } | Sort-Object
    foreach ($f in $subFiles) {
        $name = Split-Path -Leaf $f
        $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
    }
    $lines += "`t`t`t);"
    $lines += "`t`t`tpath = $gpath;"
    $lines += "`t`t`tsourceTree = `"<group>`";"
    $lines += "`t`t};"
}

# Utils group (with subgroups)
$lines += "`t`t$($Groups['Utils']) /* Utils */ = {"
$lines += "`t`t`tisa = PBXGroup;"
$lines += "`t`t`tchildren = ("
$lines += "`t`t`t`t$($Groups['Utils_Sub_Extensions']) /* Extensions */,"
$lines += "`t`t`t`t$($Groups['Utils_Sub_Enums']) /* Enums */,"
$lines += "`t`t`t`t$($Groups['Utils_Sub_Constants']) /* Constants */,"
$lines += "`t`t`t`t$($Groups['Utils_Sub_Protocols']) /* Protocols */,"
$lines += "`t`t`t`t$($Groups['Utils_Sub_Config']) /* Config */,"
$lines += "`t`t`t`t$($Groups['Utils_Sub_Debug']) /* Debug */,"
# Utils root files
$utilRootFiles = $FileRefs.Keys | Where-Object { $_ -like "CalorieTracker/Utils/*" -and (Split-Path -Parent $_) -eq "CalorieTracker/Utils" } | Sort-Object
foreach ($f in $utilRootFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`tpath = CalorieTracker/Utils;"
$lines += "`t`t`tsourceTree = `"<group>`";"
$lines += "`t`t};"

# Utils subgroups
@"
$($Groups['Utils_Sub_Extensions'])|Extensions|CalorieTracker/Utils/Extensions
$($Groups['Utils_Sub_Enums'])|Enums|CalorieTracker/Utils/Enums
$($Groups['Utils_Sub_Constants'])|Constants|CalorieTracker/Utils/Constants
$($Groups['Utils_Sub_Protocols'])|Protocols|CalorieTracker/Utils/Protocols
$($Groups['Utils_Sub_Config'])|Config|CalorieTracker/Utils/Config
$($Groups['Utils_Sub_Debug'])|Debug|CalorieTracker/Utils/Debug
"@ | ForEach-Object {
    $parts = $_ -split '\|'
    $gid = $parts[0]
    $gname = $parts[1]
    $gpath = $parts[2]
    $lines += "`t`t$gid /* $gname */ = {"
    $lines += "`t`t`tisa = PBXGroup;"
    $lines += "`t`t`tchildren = ("
    $subFiles = $FileRefs.Keys | Where-Object { $_ -like "$gpath/*" } | Sort-Object
    foreach ($f in $subFiles) {
        $name = Split-Path -Leaf $f
        $lines += "`t`t`t`t$($FileRefs[$f]) /* $name */,"
    }
    $lines += "`t`t`t);"
    $lines += "`t`t`tpath = $gpath;"
    $lines += "`t`t`tsourceTree = `"<group>`";"
    $lines += "`t`t};"
}

# PBXBuildFile
$lines += "`n`t`t/* === PBXBuildFile === */"
foreach ($k in $BuildFiles.Keys | Sort-Object) {
    $name = Split-Path -Leaf $k
    $lines += "`t`t$($BuildFiles[$k]) /* $name in Sources */ = {isa = PBXBuildFile; fileRef = $($FileRefs[$k]) /* $name */;};"
}

# PBXSourcesBuildPhase
$lines += "`n`t`t/* === PBXSourcesBuildPhase === */"
$lines += "`t`t$SourcesBuildPhase /* Sources */ = {"
$lines += "`t`t`tisa = PBXSourcesBuildPhase;"
$lines += "`t`t`tbuildActionMask = 2147483647;"
$lines += "`t`t`tfiles = ("
$swiftFiles = $BuildFiles.Keys | Where-Object { $_ -like "*.swift" } | Sort-Object
foreach ($f in $swiftFiles) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($BuildFiles[$f]) /* $name in Sources */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`trunOnlyForDeploymentPostprocessing = 0;"
$lines += "`t`t};"

# PBXFrameworksBuildPhase
$lines += "`n`t`t/* === PBXFrameworksBuildPhase === */"
$lines += "`t`t$FrameworksBuildPhase /* Frameworks */ = {"
$lines += "`t`t`tisa = PBXFrameworksBuildPhase;"
$lines += "`t`t`tbuildActionMask = 2147483647;"
$lines += "`t`t`tfiles = ("
$lines += "`t`t`t);"
$lines += "`t`t`trunOnlyForDeploymentPostprocessing = 0;"
$lines += "`t`t};"

# PBXResourcesBuildPhase
$lines += "`n`t`t/* === PBXResourcesBuildPhase === */"
$lines += "`t`t$ResourcesBuildPhase /* Resources */ = {"
$lines += "`t`t`tisa = PBXResourcesBuildPhase;"
$lines += "`t`t`tbuildActionMask = 2147483647;"
$lines += "`t`t`tfiles = ("
foreach ($f in $ResourceFiles | Sort-Object) {
    $name = Split-Path -Leaf $f
    $lines += "`t`t`t`t$($BuildFiles[$f]) /* $name in Resources */,"
}
$lines += "`t`t`t);"
$lines += "`t`t`trunOnlyForDeploymentPostprocessing = 0;"
$lines += "`t`t};"

# PBXNativeTarget
$lines += "`n`t`t/* === PBXNativeTarget === */"
$lines += "`t`t$TargetId /* CalorieTracker */ = {"
$lines += "`t`t`tisa = PBXNativeTarget;"
$lines += "`t`t`tbuildConfigurationList = $TargetConfigList /* Build configuration list for target */;"
$lines += "`t`t`tbuildPhases = ("
$lines += "`t`t`t`t$SourcesBuildPhase /* Sources */,"
$lines += "`t`t`t`t$FrameworksBuildPhase /* Frameworks */,"
$lines += "`t`t`t`t$ResourcesBuildPhase /* Resources */,"
$lines += "`t`t`t);"
$lines += "`t`t`tbuildRules = ("
$lines += "`t`t`t);"
$lines += "`t`t`tdependencies = ("
$lines += "`t`t`t);"
$lines += "`t`t`tname = `"CalorieTracker`";"
$lines += "`t`t`tproductName = `"CalorieTracker`";"
$lines += "`t`t`tproductReference = $ProductId /* CalorieTracker.app */;"
$lines += "`t`t`tproductType = `"com.apple.product-type.application`";"
$lines += "`t`t};"

# XCBuildConfiguration - Debug
$lines += "`n`t`t/* === XCBuildConfiguration Debug */"
$lines += "`t`t$DebugConfig /* Debug */ = {"
$lines += "`t`t`tisa = XCBuildConfiguration;"
$lines += "`t`t`tbuildSettings = {"
$lines += "`t`t`t`tALWAYS_SEARCH_USER_PATHS = NO;"
$lines += "`t`t`t`tCLANG_ENABLE_MODULES = YES;"
$lines += "`t`t`t`tCLANG_ENABLE_OBJC_ARC = YES;"
$lines += "`t`t`t` tGCC_C_LANGUAGE_STANDARD = gnu11;"
$lines += "`t`t`t`tGCC_OPTIMIZATION_LEVEL = 0;"
$lines += "`t`t`t`tCOPY_PHASE_STRIP = NO;"
$lines += "`t`t`t`tDEBUG_INFORMATION_FORMAT = dwarf;"
$lines += "`t`t`t`tENABLE_TESTABILITY = YES;"
$lines += "`t`t`t`tIPHONEOS_DEPLOYMENT_TARGET = 17.0;"
$lines += "`t`t`t`tSDKROOT = iphoneos;"
$lines += "`t`t`t`tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;"
$lines += "`t`t`t`tSWIFT_OPTIMIZATION_LEVEL = `"-Onone`";"
$lines += "`t`t`t`tSWIFT_VERSION = 5.9;"
$lines += "`t`t`t`tUSDA_API_KEY = `""`";"
$lines += "`t`t`t};\n"
$lines += "`t`t`tname = Debug;"
$lines += "`t`t};"

# XCBuildConfiguration - Release
$lines += "`n`t`t/* === XCBuildConfiguration Release */"
$lines += "`t`t$ReleaseConfig /* Release */ = {"
$lines += "`t`t`tisa = XCBuildConfiguration;"
$lines += "`t`t`tbuildSettings = {"
$lines += "`t`t`t`tALWAYS_SEARCH_USER_PATHS = NO;"
$lines += "`t`t`t`tCLANG_ENABLE_MODULES = YES;"
$lines += "`t`t`t`tCLANG_ENABLE_OBJC_ARC = YES;"
$lines += "`t`t`t`tGCC_C_LANGUAGE_STANDARD = gnu11;"
$lines += "`t`t`t`tGCC_OPTIMIZATION_LEVEL = s;"
$lines += "`t`t`t`tCOPY_PHASE_STRIP = NO;"
$lines += "`t`t`t`tDEBUG_INFORMATION_FORMAT = `"dwarf-with-dsym`";"
$lines += "`t`t`t`tENABLE_NS_ASSERTIONS = NO;"
$lines += "`t`t`t`tENABLE_TESTABILITY = NO;"
$lines += "`t`t`t`tIPHONEOS_DEPLOYMENT_TARGET = 17.0;"
$lines += "`t`t`t`tSDKROOT = iphoneos;"
$lines += "`t`t`t`tSWIFT_OPTIMIZATION_LEVEL = `"-O`";"
$lines += "`t`t`t`tSWIFT_VERSION = 5.9;"
$lines += "`t`t`t`tUSDA_API_KEY = `""`";"
$lines += "`t`t`t};\n"
$lines += "`t`t`tname = Release;"
$lines += "`t`t};"

# XCConfigurationList - Project
$lines += "`n`t`t/* === XCConfigurationList Project */"
$lines += "`t`t$ProjectConfigList /* Build configuration list for PBXProject */ = {"
$lines += "`t`t`tisa = XCConfigurationList;"
$lines += "`t`t`tbuildConfigurations = ("
$lines += "`t`t`t`t$ProjectDebugConfig /* Debug */,"
$lines += "`t`t`t`t$ProjectReleaseConfig /* Release */,"
$lines += "`t`t`t);"
$lines += "`t`t`tdefaultConfigurationIsVisible = 0;"
$lines += "`t`t`tdefaultConfigurationName = Release;"
$lines += "`t`t};"

# XCConfigurationList - Target
$lines += "`n`t`t/* === XCConfigurationList Target */"
$lines += "`t`t$TargetConfigList /* Build configuration list for PBXNativeTarget */ = {"
$lines += "`t`t`tisa = XCConfigurationList;"
$lines += "`t`t`tbuildConfigurations = ("
$lines += "`t`t`t`t$DebugConfig /* Debug */,"
$lines += "`t`t`t`t$ReleaseConfig /* Release */,"
$lines += "`t`t`t);"
$lines += "`t`t`tdefaultConfigurationIsVisible = 0;"
$lines += "`t`t};"

# Project debug/release configs (for the project-level)
$lines += "`n`t`t/* === Project-level configs */"
$lines += "`t`t$ProjectDebugConfig /* Debug */ = {"
$lines += "`t`t`tisa = XCBuildConfiguration;"
$lines += "`t`t`tbuildSettings = {"
$lines += "`t`t`t`tALWAYS_ENFORCE_DEPLOYMENT_TARGET = YES;"
$lines += "`t`t`t`tDEFINES_MODULE = NO;"
$lines += "`t`t`t`tMACH_O_TYPE = mh_execute;"
$lines += "`t`t`t`tONLY_ACTIVE_ARCH = YES;"
$lines += "`t`t`t\tSWIFT_OPTIMIZATION_LEVEL = `"-Onone`";"
$lines += "`t`t`t};\n"
$lines += "`t`t`tname = Debug;"
$lines += "`t`t};"

$lines += "`t`t/* === Project-level configs */"
$lines += "`t`t$ProjectReleaseConfig /* Release */ = {"
$lines += "`t`t`tisa = XCBuildConfiguration;"
$lines += "`t`t`tbuildSettings = {"
$lines += "`t`t`t`tALWAYS_ENFORCE_DEPLOYMENT_TARGET = YES;"
$lines += "`t`t`t`tDEFINES_MODULE = NO;"
$lines += "`t`t`t`tMACH_O_TYPE = mh_execute;"
$lines += "`t`t`t\tSWIFT_OPTIMIZATION_LEVEL = `"-O`";"
$lines += "`t`t`t};\n"
$lines += "`t`t`tname = Release;"
$lines += "`t`t};"

# PBXProject
$lines += "`n`t`t/* === PBXProject === */"
$lines += "`t`t$pbx_project /* Project object */ = {"
$lines += "`t`t`tisa = PBXProject;"
$lines += "`t`t`tbuildConfigurationList = $ProjectConfigList /* Build configuration list for PBXProject */;"
$lines += "`t`t`tcompatibilityVersion = `"Xcode 15.0`";"
$lines += "`t`t`tdevelopmentRegion = en;"
$lines += "`t`t`thasScannedForEncodings = 0;"
$lines += "`t`t`tknownRegions = ("
$lines += "`t`t`t`ten,"
$lines += "`t`t`t);"
$lines += "`t`t`tmainGroup = $RootGroupId;"
$lines += "`t`t`tproductRefGroup = $RootGroupId;"
$lines += "`t`t`tprojectDirPath = `"";`"
$lines += "`t`t`tprojectRoot = `"";`"
$lines += "`t`t	targets = ("
$lines += "`t`t`t`t$TargetId /* CalorieTracker */,"
$lines += "`t`t`t);`
$lines += "`t`t};"

$lines += "`t};"
$lines += "`trootObject = $pbx_project /* Project object */;"
$lines += "}"

$content = $lines -join "`n"
$content | Set-Content -Path (Join-Path $ProjectDir "project.pbxproj") -Encoding UTF8
Write-Host "Generated $(Join-Path $ProjectDir "project.pbxproj")"
Write-Host "Total Swift files: $($SourceFiles.Count)"
Write-Host "Total Resource files: $($ResourceFiles.Count)"