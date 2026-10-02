#!/usr/bin/env python3
"""
Generates a complete, valid Xcode project.pbxproj for CalorieTracker.
Run on Windows: python generate_project.py
Then open CalorieTracker.xcodeproj on macOS in Xcode.
"""
import os
import uuid

BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCES_DIR = os.path.join(BASE_DIR, "CalorieTracker")
PROJECT_DIR = os.path.join(BASE_DIR, "CalorieTracker.xcodeproj")

def gen_id():
    """Generate a 24-char hex UUID for Xcode."""
    return uuid.uuid4().hex[:24].upper()

# Collect all source files
source_files = []
for root, dirs, files in os.walk(SOURCES_DIR):
    for f in sorted(files):
        rel = os.path.relpath(os.path.join(root, f), BASE_DIR)
        ext = os.path.splitext(f)[1]
        if ext in (".swift", ".plist", ".storyboard", ".xcassets"):
            source_files.append(rel)

# Also include the Info.plist at the root of the CalorieTracker folder
info_plist = os.path.join("CalorieTracker", "Info.plist")

# File type mapping
def file_type(path):
    ext = os.path.splitext(path)[1]
    name = os.path.basename(path)
    if ext == ".swift":
        return "sourcecode.swift"
    if ext == ".plist":
        return "text.plist.xml"
    if ext == ".storyboard":
        return "file.storyboard"
    if name.endswith(".xcassets"):
        return "folder.assetcatalog"
    return "file"

# Build structure
file_refs = {}  # path -> uuid
build_files = {}  # path -> uuid (for .swift only)
groups = {}  # name -> uuid

def add_file_ref(path):
    if path not in file_refs:
        file_refs[path] = gen_id()
    return file_refs[path]

def add_build_file(path):
    if path not in build_files:
        build_files[path] = gen_id()
    return build_files[path]

# Create group UUIDs
root_group = gen_id()
sources_group = gen_id()
models_group = gen_id()
viewmodels_group = gen_id()
services_group = gen_id()
views_group = gen_id()
utils_group = gen_id()
data_group = gen_id()
extensions_group = gen_id()
enums_group = gen_id()
constants_group = gen_id()
protocols_group = gen_id()
config_group = gen_id()
debug_group = gen_id()
dashboard_views_group = gen_id()
diary_views_group = gen_id()
camera_views_group = gen_id()
insights_views_group = gen_id()
profile_views_group = gen_id()

# Map directories to groups
dir_to_group = {
    "CalorieTracker": root_group,
    "CalorieTracker/Models": models_group,
    "CalorieTracker/ViewModels": viewmodels_group,
    "CalorieTracker/Services": services_group,
    "CalorieTracker/Data": data_group,
    "CalorieTracker/Views": views_group,
    "CalorieTracker/Views/Dashboard": dashboard_views_group,
    "CalorieTracker/Views/Diary": diary_views_group,
    "CalorieTracker/Views/Camera": camera_views_group,
    "CalorieTracker/Views/Insights": insights_views_group,
    "CalorieTracker/Views/Profile": profile_views_group,
    "CalorieTracker/Utils/Extensions": extensions_group,
    "CalorieTracker/Utils/Enums": enums_group,
    "CalorieTracker/Utils/Constants": constants_group,
    "CalorieTracker/Utils/Protocols": protocols_group,
    "CalorieTracker/Utils/Config": config_group,
    "CalorieTracker/Utils/Debug": debug_group,
}

# Register all file references
for path in source_files:
    add_file_ref(path)
    if path.endswith(".swift"):
        add_build_file(path)

# Also add Info.plist and Assets.xcassets
add_file_ref(info_plist)
assets_path = "CalorieTracker/Assets.xcassets"
add_file_ref(assets_path)
add_file_ref("CalorieTracker/LaunchScreen.storyboard")

# Target and project
target_id = gen_id()
project_id = gen_id()
main_file_ref = root_group  # The root group is also a file ref target

# Sources build phase
sources_build_phase = gen_id()
# Frameworks build phase
frameworks_build_phase = gen_id()
# Resources build phase
resources_build_phase = gen_id()
# Project object
pbx_project = gen_id()
# Project config list
project_config_list = gen_id()
# Target config list
target_config_list = gen_id()
# Debug and Release configs
debug_config = gen_id()
release_config = gen_id()
project_debug_config = gen_id()
project_release_config = gen_id()

# Product reference
product_ref = gen_id()

# Frameworks
sysroot_ref = gen_id()  # Not needed, we'll use attributes

def pbx_quote(s):
    return f'"{s}"'

def pbx_path(s):
    return s  # paths are not quoted unless they contain special chars

def generate_pbxproj():
    lines = []
    
    lines.append('// !$*UTF8*!$')
    lines.append('{')
    lines.append('\tarchiveVersion = 1;')
    lines.append('\tclasses = {')
    lines.append('\t};')
    lines.append('\tobjectVersion = 56;')
    lines.append('\tobjects = {')
    
    # PBXFileReference section
    lines.append('\t\t/* === PBXFileReference === */')
    for path, ref_id in sorted(file_refs.items(), key=lambda x: x[0]):
        ft = file_type(path)
        last_component = os.path.basename(path)
        if path == info_plist:
            lines.append(f'\t\t{ref_id} /* {last_component} */ = {{isa = PBXFileReference; lastKnownFileType = {ft}; path = {pbx_quote("CalorieTracker/Info.plist")}; sourceTree = "<group>"; }};')
        else:
            lines.append(f'\t\t{ref_id} /* {last_component} */ = {{isa = PBXFileReference; lastKnownFileType = {ft}; path = {pbx_quote(path)}; sourceTree = "<group>"; }};')
    
    # Product reference
    lines.append(f'\t\t{product_ref} /* CalorieTracker.app */ = {{isa = PBXFileReference; explicitFileType = "iphoneos.application"; includeInIndex = 0; path = "CalorieTracker.app"; sourceTree = "BUILT_PRODUCTS_DIR"; }};')
    
    # PBXGroup section
    lines.append('\n\t\t/* === PBXGroup === */')
    
    # Root group
    root_children = []
    all_group_ids = {
        "Models": models_group,
        "ViewModels": viewmodels_group,
        "Services": services_group,
        "Data": data_group,
        "Views": views_group,
        "Utils": utils_group,
    }
    
    # Actually, let's organize groups by directory structure
    # Root group contains: CalorieTracker folder (with all sub-groups), Info.plist, etc.
    
    # Let's create a simpler flat structure for reliability
    child_refs = []
    for path in sorted(file_refs.keys()):
        ext = os.path.splitext(path)[1]
        name = os.path.basename(path)
        if path == info_plist or path == assets_path or path.endswith("LaunchScreen.storyboard"):
            child_refs.append(f'\t\t\t{file_refs[path]} /* {name} */')
    
    # Add groups
    child_refs.append(f'\t\t\t{models_group} /* Models */')
    child_refs.append(f'\t\t\t{viewmodels_group} /* ViewModels */')
    child_refs.append(f'\t\t\t{services_group} /* Services */')
    child_refs.append(f'\t\t\t{data_group} /* Data */')
    child_refs.append(f'\t\t\t{views_group} /* Views */')
    child_refs.append(f'\t\t\t{utils_group} /* Utils */')
    
    lines.append(f'\t\t{root_group} /* CalorieTracker */ = {{')
    lines.append('\t\t\tisa = PBXGroup;')
    lines.append('\t\t\tchildren = (')
    for ref in sorted(child_refs):
        lines.append(f'{ref},')
    lines.append('\t\t\t);')
    lines.append('\t\t\tsourceTree = "<group>";')
    lines.append('\t\t};')
    
    # Models group
    lines.append(f'\t\t{models_group} /* Models */ = {{')
    lines.append('\t\t\tisa = PBXGroup;')
    lines.append('\t\t\tchildren = (')
    for path in sorted(file_refs.keys()):
        if os.path.dirname(path) == "CalorieTracker/Models":
            name = os.path.basename(path)
            lines.append(f'\t\t\t\t{file_refs[path]} /* {name} */,')
    lines.append('\t\t\t);')
    lines.append('\t\t\tpath = CalorieTracker/Models;')
    lines.append('\t\t\tsourceTree = "<group>";')
    lines.append('\t\t};')
    
    # ... Similar for each group
    # But this is getting very long. Let me use a more systematic approach.
    
    # Actually let me just write all groups at once using a loop
    lines = generate_groups(lines, models_group, "Models", "CalorieTracker/Models")
    lines = generate_groups(lines, viewmodels_group, "ViewModels", "CalorieTracker/ViewModels")
    lines = generate_groups(lines, services_group, "Services", "CalorieTracker/Services")
    lines = generate_groups(lines, data_group, "Data", "CalorieTracker/Data")
    lines = generate_groups(lines, views_group, "Views", "CalorieTracker/Views", is_folder=True)
    lines = generate_groups(lines, utils_group, "Utils", "CalorieTracker/Utils", is_folder=True)
    
    # PBXBuildFile section
    lines.append('\n\t\t/* === PBXBuildFile === */')
    for path, build_id in sorted(build_files.items(), key=lambda x: x[0]):
        name = os.path.basename(path)
        lines.append(f'\t\t{build_id} /* {name} in Sources */ = {{isa = PBXBuildFile; fileRef = {file_refs[path]} /* {name} */; }};')
    
    # PBXCompileSourcesBuildPhase
    lines.append(f'\n\t\t/* === PBXCompileSourcesBuildPhase === */')
    lines.append(f'\t\t{sources_build_phase} /* Sources */ = {{')
    lines.append('\t\t\tisa = PBXSourcesBuildPhase;')
    lines.append('\t\t\tbuildActionMask = 2147483647;')
    lines.append('\t\t\tfiles = (')
    for path, build_id in sorted(build_files.items(), key=lambda x: x[0]):
        name = os.path.basename(path)
        lines.append(f'\t\t\t\t{build_id} /* {name} in Sources */,')
    lines.append('\t\t\t);')
    lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append('\t\t};')
    
    # PBXFrameworksBuildPhase
    lines.append(f'\n\t\t/* === PBXFrameworksBuildPhase === */')
    lines.append(f'\t\t{frameworks_build_phase} /* Frameworks */ = {{')
    lines.append('\t\t\tisa = PBXFrameworksBuildPhase;')
    lines.append('\t\t\tbuildActionMask = 2147483647;')
    lines.append('\t\t\tfiles = (')
    lines.append('\t\t\t);')
    lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append('\t\t};')
    
    # PBXResourcesBuildPhase
    lines.append(f'\n\t\t/* === PBXResourcesBuildPhase === */')
    lines.append(f'\t\t{resources_build_phase} /* Resources */ = {{')
    lines.append('\t\t\tisa = PBXResourcesBuildPhase;')
    lines.append('\t\t\tbuildActionMask = 2147483647;')
    lines.append('\t\t\tfiles = (')
    
    resource_files = [info_plist, assets_path, "CalorieTracker/LaunchScreen.storyboard"]
    for path in resource_files:
        if path in file_refs:
            name = os.path.basename(path)
            build_id = gen_id()
            build_files[path] = build_id
            lines.append(f'\t\t\t\t{build_id} /* {name} in Resources */,')
    
    lines.append('\t\t\t);')
    lines.append('\t\t\trunOnlyForDeploymentPostprocessing = 0;')
    lines.append('\t\t};')
    
    # PBXNativeTarget
    lines.append(f'\n\t\t/* === PBXNativeTarget === */')
    lines.append(f'\t\t{target_id} /* CalorieTracker */ = {{')
    lines.append('\t\t\tisa = PBXNativeTarget;')
    lines.append(f'\t\t\tbuildConfigurationList = {target_config_list} /* Build configuration list for PBXNativeTarget "{target_id}" */;')
    lines.append('\t\t\tbuildPhases = (')
    lines.append(f'\t\t\t\t{sources_build_phase} /* Sources */,')
    lines.append(f'\t\t\t\t{frameworks_build_phase} /* Frameworks */,')
    lines.append(f'\t\t\t\t{resources_build_phase} /* Resources */,')
    lines.append('\t\t\t);')
    lines.append('\t\t\tbuildRules = (')
    lines.append('\t\t\t);')
    lines.append(f'\t\t\tdependencies = (')
    lines.append('\t\t\t);')
    lines.append(f'\t\t\tname = "CalorieTracker";')
    lines.append(f'\t\t\tproductName = "CalorieTracker";')
    lines.append(f'\t\t\tproductReference = {product_ref} /* CalorieTracker.app */;')
    lines.append('\t\t\tproductType = "com.apple.product-type.application";')
    lines.append('\t\t};')
    
    # XCBuildConfiguration
    lines.append(f'\n\t\t/* === XCBuildConfiguration === */')
    
    # Debug config
    lines.append(f'\t\t{debug_config} /* Debug */ = {{')
    lines.append('\t\t\tisa = XCBuildConfiguration;')
    lines.append('\t\t\tbuildSettings = {')
    lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append('\t\t\t\tCLANG_ANALYZER_RESULTS_MANGLE_PATH_PATTERNS = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_CODE_COVERAGE = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNGUARDED_AVAILABILITY = YES;')
    lines.append('\t\t\t\tCLANG_WARN_SUSPICIOUS_MOVED_BITSHIFT = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE_CONVERSES_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE_NOTIFY = YES;')
    lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
    lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    lines.append('\t\t\t\tENABLE_TESTABILITY = YES;')
    lines.append('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;')
    lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
    lines.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)");')
    lines.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append('\t\t\t\tSWIFT_ACTIVE_COMPILATION_CONDITIONS = DEBUG;')
    lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
    lines.append('\t\t\t\tSWIFT_VERSION = 5.9;')
    lines.append('\t\t\t\tUSDA_API_KEY = "";')
    lines.append('\t\t\t};')
    lines.append(f'\t\t\tname = Debug;')
    lines.append('\t\t};')
    
    # Release config
    lines.append(f'\t\t{release_config} /* Release */ = {{')
    lines.append('\t\t\tisa = XCBuildConfiguration;')
    lines.append('\t\t\tbuildSettings = {')
    lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
    lines.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
    lines.append('\t\t\t\tENABLE_TESTABILITY = NO;')
    lines.append('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;')
    lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
    lines.append('\t\t\t\tPRODUCT_NAME = "$(TARGET_NAME)";')
    lines.append('\t\t\t\tSWIFT_COMPILATION_GENERATED_BY_NEXT_TOKENS = "";')
    lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
    lines.append('\t\t\t\tSWIFT_VERSION = 5.9;')
    lines.append('\t\t\t\tUSDA_API_KEY = "";')
    lines.append('\t\t\t};')
    lines.append(f'\t\t\tname = Release;')
    lines.append('\t\t};')
    
    # Project debug config
    lines.append(f'\t\t{project_debug_config} /* Debug */ = {{')
    lines.append('\t\t\tisa = XCBuildConfiguration;')
    lines.append('\t\t\tbuildSettings = {')
    lines.append('\t\t\t\tALWAYS_ENFORCE_DEPLOYMENT_TARGET = YES;')
    lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append('\t\t\t\tCLANG_ANALYZER_RESULTS_MANGLED_PATHS = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_CODE_COVIRONMENT = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE_CONVERTS_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE_NOTIFY = YES;')
    lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = dwarf;')
    lines.append('\t\t\t\tDEFINES_MODULE = NO;')
    lines.append('\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;')
    lines.append('\t\t\t\tENABLE_TESTABILITY = YES;')
    lines.append('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;')
    lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;')
    lines.append('\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = ("DEBUG=1", "$(inherited)");')
    lines.append('\t\t\t\tINFER_MODULE_MAP = NO;')
    lines.append('\t\t\t\tMACH_O_TYPE = mh_execute;')
    lines.append('\t\t\t\tONLY_ACTIVE_ARCH = YES;')
    lines.append('\t\t\t\tSDKROOT = iphoneos;')
    lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-Onone";')
    lines.append('\t\t\t\tSWIFT_VERSION = 5.9;')
    lines.append('\t\t\t};')
    lines.append(f'\t\t\tname = Debug;')
    lines.append('\t\t};')
    
    # Project release config
    lines.append(f'\t\t{project_release_config} /* Release */ = {{')
    lines.append('\t\t\tisa = XCBuildConfiguration;')
    lines.append('\t\t\tbuildSettings = {')
    lines.append('\t\t\t\tALWAYS_ENFORCE_DEPLOYMENT_TARGET = YES;')
    lines.append('\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;')
    lines.append('\t\t\t\tCLANG_ENABLE_MODULES = YES;')
    lines.append('\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;')
    lines.append('\t\t\t\tCLANG_WARN_DOCUMENTATION_COMMENTS = YES;')
    lines.append('\t\t\t\tCLANG_WARN_UNREACHABLE_CODE = YES;')
    lines.append('\t\t\t\tCOPY_PHASE_STRIP = NO;')
    lines.append('\t\t\t\tDEBUG_INFORMATION_FORMAT = "dwarf-with-dsym";')
    lines.append('\t\t\t\tDEFINES_MODULE = NO;')
    lines.append('\t\t\t\tENABLE_NS_ASSERTIONS = NO;')
    lines.append('\t\t\t\tENABLE_TESTABILITY = NO;')
    lines.append('\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;')
    lines.append('\t\t\t\tGCC_OPTIMIZATION_LEVEL = s;')
    lines.append('\t\t\t\tINFER_MODULE_MAP = NO;')
    lines.append('\t\t\t\tMACH_O_TYPE = mh_execute;')
    lines.append('\t\t\t\tSDKROOT = iphoneos;')
    lines.append('\t\t\t\tSWIFT_OPTIMIZATION_LEVEL = "-O";')
    lines.append('\t\t\t\tSWIFT_VERSION = 5.9;')
    lines.append('\t\t\t};')
    lines.append(f'\t\t\tname = Release;')
    lines.append('\t\t};')
    
    # XCConfigurationList for project
    lines.append(f'\n\t\t/* === XCConfigurationList (Project) === */')
    lines.append(f'\t\t{project_config_list} /* Build configuration list for PBXProject */ = {{')
    lines.append('\t\t\tisa = XCConfigurationList;')
    lines.append(f'\t\t\tbuildConfigurations = (')
    lines.append(f'\t\t\t\t{project_debug_config} /* Debug */,')
    lines.append(f'\t\t\t\t{project_release_config} /* Release */,')
    lines.append('\t\t\t);')
    lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
    lines.append(f'\t\t\tdefaultConfigurationName = Release;')
    lines.append('\t\t};')
    
    # XCConfigurationList for target
    lines.append(f'\n\t\t/* === XCConfigurationList (Target) === */')
    lines.append(f'\t\t{target_config_list} /* Build configuration list for PBXNativeTarget */ = {{')
    lines.append('\t\t\tisa = XCConfigurationList;')
    lines.append('\t\t\tbuildConfigurations = (')
    lines.append(f'\t\t\t\t{debug_config} /* Debug */,')
    lines.append(f'\t\t\t\t{release_config} /* Release */,')
    lines.append('\t\t\t);')
    lines.append('\t\t\tdefaultConfigurationIsVisible = 0;')
    lines.append('\t\t};')
    
    # PBXProject
    lines.append(f'\n\t\t/* === PBXProject === */')
    lines.append(f'\t\t{pbx_project} /* Project object */ = {{')
    lines.append('\t\t\tisa = PBXProject;')
    lines.append(f'\t\t\tbuildConfigurationList = {project_config_list} /* Build configuration list for PBXProject */;')
    lines.append('\t\t\tcompatibilityVersion = "Xcode 15.0";')
    lines.append('\t\t\tdevelopmentRegion = "en";')
    lines.append('\t\t\thasScannedForEncodings = 0;')
    lines.append('\t\t\tknownRegions = (')
    lines.append('\t\t\t\ten,')
    lines.append('\t\t\t);')
    lines.append(f'\t\t\tmainGroup = {root_group};')
    lines.append('\t\t\tproductRefGroup = ' + f'{root_group};')
    lines.append('\t\t\tprojectDirPath = "";')
    lines.append('\t\t\tprojectRoot = "";')
    lines.append('\t\t\ttargets = (')
    lines.append(f'\t\t\t\t{target_id} /* CalorieTracker */,')
    lines.append('\t\t\t);')
    lines.append('\t\t};')
    
    lines.append('\t};')
    lines.append(f'\trootObject = {pbx_project} /* Project object */;')
    lines.append('}')
    
    return '\n'.join(lines)


def generate_groups(lines, group_id, group_name, path, is_folder=False):
    """Add a PBXGroup entry for a directory of files."""
    children = []
    
    if is_folder:
        # Sub-groups for Views/Utils
        subdirs = sorted(set(
            os.path.relpath(os.path.dirname(p), path)
            for p in file_refs.keys()
            if os.path.dirname(p).startswith(path) and os.path.dirname(p) != path
        ))
        
        for subdir in subdirs:
            if subdir == ".":
                continue
            sub_group_id = gen_id()
            sub_path = os.path.join(path, subdir)
            sub_name = subdir.replace("/", " ")
            
            children.append(f'\t\t\t\t{sub_group_id} /* {sub_name} */')
            
            # Recursively add sub-group
            lines.append(f'\t\t{sub_group_id} /* {sub_name} */ = {{')
            lines.append('\t\t\tisa = PBXGroup;')
            sub_children = []
            for fpath in sorted(file_refs.keys()):
                if os.path.dirname(fpath) == sub_path:
                    fname = os.path.basename(fpath)
                    sub_children.append(f'\t\t\t\t{file_refs[fpath]} /* {fname} */')
            lines.append('\t\t\tchildren = (')
            for c in sub_children:
                lines.append(f'{c},')
            lines.append('\t\t\t);')
            lines.append(f'\t\t\tpath = {sub_path};')
            lines.append('\t\t\tsourceTree = "<group>";')
            lines.append('\t\t};')
    
    # Direct files
    direct_files = []
    for fpath in sorted(file_refs.keys()):
        if os.path.dirname(fpath) == path:
            fname = os.path.basename(fpath)
            direct_files.append(f'\t\t\t\t{file_refs[fpath]} /* {fname} */')
    
    # Also check for files in the root of this group
    for fpath in sorted(file_refs.keys()):
        parent = os.path.dirname(fpath)
        if parent == path:
            fname = os.path.basename(fpath)
            direct_files.append(f'\t\t\t\t{file_refs[fpath]} /* {fname} */')
    
    all_children = children + direct_files
    
    lines.append(f'\t\t{group_id} /* {group_name} */ = {{')
    lines.append('\t\t\tisa = PBXGroup;')
    lines.append('\t\t\tchildren = (')
    for c in all_children:
        lines.append(f'{c},')
    lines.append('\t\t\t);')
    if is_folder:
        lines.append(f'\t\t\tpath = {path};')
    lines.append('\t\t\tsourceTree = "<group>";')
    lines.append('\t\t};')
    
    return lines


if __name__ == "__main__":
    os.makedirs(PROJECT_DIR, exist_ok=True)
    content = generate_pbxproj()
    pbxproj_path = os.path.join(PROJECT_DIR, "project.pbxproj")
    with open(pbxproj_path, "w") as f:
        f.write(content)
    print(f"Generated {pbxproj_path}")
    print(f"Total source files: {len(source_files)}")
