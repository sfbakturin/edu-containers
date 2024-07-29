import os
import sys
import subprocess
import yaml

from typing import List, Dict

# compile.py is a utility script created exclusively for `edu-containers` (https://github.com/sfbakturin/edu-containers)
# that generates and runs the compile command.

# Utils.

class CMDElement:
	def __init__(self, x: str):
		xs = x.split("=")
		if len(xs) != 2:
			raise ValueError("String for CMDElement should have format as \"--<flag>=<value>\"")
		self.__flag = xs[0]
		if self.__flag.startswith("--"):
			self.__flag = self.__flag[2:]
		else:
			raise ValueError("Flag for CMDElement should have format as \"--<char sequence>\"")
		self.__values = xs[1].split(",")

	def get_flag(self) -> str:
		return self.__flag

	def get_values(self) -> List[str]:
		return self.__values

class Library:
	def __init__(self, parsed: Dict[str, str]):
		self.__name = self.__get_from("name", parsed)
		self.__include_directory = self.__parsed_directory(self.__get_from("includedir", parsed), "includedir")
		self.__library_directory = self.__parsed_directory(self.__get_from("librarydir", parsed), "librarydir")

	@staticmethod
	def __get_from(n: str, d: Dict[str, str]) -> str:
		if not n in d:
			raise LookupError("In library settings there must be \"%s\" option" % (n))
		return d[n]

	@staticmethod
	def __parsed_directory(d: str, d_name: str) -> str:
		asenv = os.getenv(d)
		if asenv is None:
			if not os.path.exists(d):
				raise FileNotFoundError("Provided path and env-as-path \"%s\" as %s not exists" % (d, d_name))
			return d
		else:
			if not os.path.exists(asenv):
				raise FileNotFoundError("Provided \"%s\" as %s not exists" % (asenv, d_name))
			return asenv

	def get_name(self) -> str:
		return self.__name

	def get_include(self) -> str:
		return self.__include_directory

	def get_library(self) -> str:
		return self.__library_directory

# Compilers.

class MSVCCompiler:
	def __init__(self):
		self.__defines: List[str] = []
		self.__standard: str = None
		self.__optimizations: List[str] = []
		self.__use_address_sanitizer = False
		self.__warnings: List[str] = []
		self.__sources: List[str] = []
		self.__includes: List[str] = []
		self.__lib_paths: List[str] = []
		self.__libs: List[str] = []

	def use_profile(self, name_profile: str):
		# No CL's secure warnings.
		self.__defines.append('_CRT_SECURE_NO_WARNINGS')

		# Set to max warnings CL's level.
		self.__warnings.append('W4')

		if name_profile == 'Release':
			# Generate optimized code.
			self.__optimizations.append('O2')
		elif name_profile == 'Debug':
			# Generate code with debug information.
			self.__optimizations.append('Od')
		elif name_profile == 'AddressSanitized':
			# Generate code with even more debug information.
			self.__optimizations.append('Od')
			self.__optimizations.append('Z7')
			# Set address sanitizer to use.
			self.__use_address_sanitizer = True
			# Turn off any strange CL's ASan behavior.
			self.__defines.append('_DISABLE_VECTOR_ANNOTATION')
			self.__defines.append('_DISABLE_STRING_ANNOTATION')
		else:
			raise ValueError('Found unsupported profile \"%s\" for compiling' % (name_profile))

	def set_standard(self, name_std: str):
		self.__standard = name_std

	def add_source(self, path_source: str):
		if not os.path.exists(path_source):
			raise ValueError("Source \"%s\" is not exists" % (path_source))
		self.__sources.append(path_source)

	def add_sources(self, path_sources: List[str]):
		for p in path_sources:
			self.add_source(p)

	def include_directory(self, path_include: str):
		if not os.path.exists(path_include):
			raise ValueError("Provided path for including headers \"%s\" is not exists" % (path_include))
		self.__includes.append(path_include)

	def append_lib_path(self, path_lib_path: str):
		if not os.path.exists(path_lib_path):
			raise ValueError("Provided path for including libraries \"%s\" is not exists" % (path_lib_path))
		self.__lib_paths.append(path_lib_path)

	def add_library(self, name_lib: str):
		self.__libs.append(name_lib)

	def finalize(self, name_executable: str) -> List[str]:
		cmd: List[str] = ["cl"]

		cmd.append("/EHsc")

		for define in self.__defines:
			cmd.append("/D" + define)

		if self.__standard:
			cmd.append("/" + "std" + ":" + self.__standard)

		for optimization in self.__optimizations:
			cmd.append("/" + optimization)

		for warning in self.__warnings:
			cmd.append("/" + warning)

		if self.__use_address_sanitizer:
			cmd.append("/" + "fsanitize" + "=" + "address")

		for source in self.__sources:
			cmd.append(source)

		for include in self.__includes:
			cmd.append("/I")
			cmd.append("\"" + include + "\"")

		cmd.append("/" + "link")

		for lib_path in self.__lib_paths:
			cmd.append("/" + "LIBPATH" + ":" + "\"" + lib_path + "\"")

		for lib in self.__libs:
			cmd.append(lib + "." + "lib")

		cmd.append("/" + "OUT" + ":" + name_executable)

		return cmd

class CCBuilder:
	def __init__(self, is_cxx: bool, name_executable: str = None):
		self.__CCBuilder_is_cxx = is_cxx
		self.__CCBuilder_name_executable = name_executable
		self.__CCBuilder_std_flags = []
		self.__CCBuilder_bt_flags = []
		self.__CCBuilder_san_flags = []
		self.__CCBuilder_warn_flags = ["-Wall", "-Wextra", "-Wpedantic"]
		self.__CCBuilder_comp_flags =[]
		self.__CCBuilder_inc_flags = []
		self.__CCBuilder_src_flags = []
		self.__CCBuilder_lib_flags = []
		self.__CCBuilder_ld_flags = []

	def set_release(self):
		self.__CCBuilder_bt_flags = ["-O2"]

	def set_debug(self):
		self.__CCBuilder_bt_flags = ["-O0", "-g"]

	def set_sanitizer(self, name_sanitize: str):
		if name_sanitize.lower() == "none":
			return
		self.__CCBuilder_san_flags = ["-fno-sanitize-recover=all", "-fsanitize=" + name_sanitize]

	def set_name_executable(self, name_executable: str):
		self.__CCBuilder_name_executable = name_executable

	def set_standard(self, std: str):
		self.__CCBuilder_std_flags = ["--std=" + std]

	def add_compile_flag(self, flag: str):
		self.__CCBuilder_comp_flags.append("-" + flag)

	def add_link_flag(self, flag: str):
		self.__CCBuilder_ld_flags.append("-" + flag)

	def include_headers(self, path_include: str, is_library: bool):
		if is_library:
			self.__CCBuilder_inc_flags.append("-isystem")
		else:
			self.__CCBuilder_inc_flags.append("-I")
		if not os.path.exists(path_include):
			raise ValueError("Provided path for including headers \"%s\" is not exists" % (path_include))
		self.__CCBuilder_inc_flags.append(path_include)

	def add_library(self, path_include: str):
		if not os.path.exists(path_include):
			raise ValueError("Provided path for including libraries \"%s\" is not exists" % (path_include))
		self.__CCBuilder_lib_flags.append("-L")
		self.__CCBuilder_lib_flags.append(path_include)

	def add_source(self, path_source: str):
		if not os.path.exists(path_source):
			raise ValueError("Source \"%s\" is not exists" % (path_source))
		self.__CCBuilder_src_flags.append(path_source)

	def add_sources(self, path_sources: List[str]):
		for p in path_sources:
			self.add_source(p)

	def link_library(self, name_library: str):
		self.__CCBuilder_ld_flags.append("-l" + name_library)

	def get_command(self) -> List[str]:
		cmd: List[str] = []

		if self.__CCBuilder_is_cxx:
			cmd = ["c++"]
		else:
			cmd = ["cc"]

		if len(self.__CCBuilder_std_flags) != 0:
			cmd += self.__CCBuilder_std_flags

		cmd += self.__CCBuilder_warn_flags

		if len(self.__CCBuilder_bt_flags) == 0:
			raise ValueError("Command for compiling should be provided by build-type")
		cmd += self.__CCBuilder_bt_flags

		if len(self.__CCBuilder_san_flags) != 0:
			cmd += self.__CCBuilder_san_flags

		if len(self.__CCBuilder_comp_flags) != 0:
			cmd += self.__CCBuilder_comp_flags

		if len(self.__CCBuilder_inc_flags):
			cmd += self.__CCBuilder_inc_flags

		if len(self.__CCBuilder_src_flags) == 0:
			raise ValueError("No sources were provided to compile command")
		cmd += self.__CCBuilder_src_flags
	
		if len(self.__CCBuilder_lib_flags) != 0:
			cmd += self.__CCBuilder_lib_flags

		if self.__CCBuilder_name_executable is None:
			raise ValueError("Unknown executable name")

		if len(self.__CCBuilder_ld_flags) != 0:
			cmd += self.__CCBuilder_ld_flags

		cmd += ["-o", self.__CCBuilder_name_executable]

		return cmd

# Environment.

def envname(name: str) -> str:
	return "EDUCONTAINER_%s" % (name.upper())

def getenv(name: str) -> str:
	value = os.getenv(envname(name))
	if value is None:
		raise ValueError("Environment variable \"%s\" must exist" % (name))
	return value

# Compile script.

DIRNAME_COMPILE_CONFIGS = ".compileconfig"

libs: Dict[str, Library] = {}

## Find and load compile script configs.

parent = None

for d in [".", os.path.expanduser("~")]:
	p = os.path.join(d, DIRNAME_COMPILE_CONFIGS)
	if os.path.exists(p):
		parent = p
		break

if parent is None:
	print("[WARN] No %s directory found, no libraries loaded." % (DIRNAME_COMPILE_CONFIGS))
else:
	for f in os.listdir(parent):
		p = os.path.join(parent, f)
		stream = open(p, "r")
		lib = Library(yaml.safe_load(stream))
		libs[lib.get_name()] = lib

## Find sources.

sources = []
is_cxx = False

for d in [".", "src"]:
	if not os.path.exists(d):
		continue
	for f in os.listdir(d):
		p = os.path.join(d, f)
		if p.endswith(".cpp") or p.endswith(".cxx"):
			is_cxx = True
			sources.append(p)
		elif p.endswith(".c") or p.endswith(".cc"):
			sources.append(p)

## Build command.

target = getenv('target')

if target == 'windows':
	cc = MSVCCompiler()
	name_executable = None

	def include_libraries(arr: List[str]):
		global cc
		for a in arr:
			if not a in libs:
				raise ValueError("Library \"%s\" no found in loader" % (a))
			cc.append_lib_path(libs[a].get_library())
			cc.include_directory(libs[a].get_include())

	def link_libraries(arr: List[str]):
		global cc
		for a in arr:
			cc.add_library(a)

	def set_standard(arr: List[str]):
		global cc
		if len(arr) != 1:
			raise ValueError("For executable name there's should be exactly one value")
		cc.set_standard(arr[0])

	def use_profile(arr: List[str]):
		global cc
		if len(arr) != 1:
			raise ValueError("For using profile there's should be exactly one value")
		cc.use_profile(arr[0])

	for i in range(1, len(sys.argv)):
		arg = CMDElement(sys.argv[i])
		flag = arg.get_flag()
		vals = arg.get_values()
		match flag:
			case "include-libraries": include_libraries(vals)
			case "link-libraries": link_libraries(vals)
			case "std": set_standard(vals)
			case "use-profile": use_profile(vals)
			case _: raise NotImplementedError("Flag \"%s\" is not supported" % (flag))

	cc.add_sources(sources)
	if os.path.exists("include"):
		cc.include_directory("include")

	## Run compilation.

	if name_executable is None:
		raise ValueError("Executable filename must be provided")

	command = cc.finalize(name_executable)
	print(" ".join(command))
	exit(subprocess.run(command).returncode)

else: # FIXME: Temporary dirty for simple testing.
	cc = CCBuilder(is_cxx)

	def include_libraries(arr: List[str]):
		global cc

		for a in arr:
			if not a in libs:
				raise ValueError("Library \"%s\" no found in loader" % (a))

			cc.add_library(libs[a].get_library())
			cc.include_headers(libs[a].get_include(), True)

	def link_libraries(arr: List[str]):
		global cc

		for a in arr:
			cc.link_library(a)

	def build_type(arr: List[str]):
		global cc

		if len(arr) != 1:
			raise ValueError("For build-type flag there's should be exactly one value")

		a = arr[0].lower()
		if a == "release":
			cc.set_release()
		elif a == "debug":
			cc.set_debug()
		else:
			raise ValueError("Unsupported build-type (\"%s\") found" % (a))

	def use_sanitizer(arr: List[str]):
		global cc

		if len(arr) != 1:
			raise ValueError("For sanitizer there's should be exactly one value")

		cc.set_sanitizer(arr[0])

	def set_name(arr: List[str]):
		global cc

		if len(arr) != 1:
			raise ValueError("For executable name there's should be exactly one value")

		cc.set_name_executable(arr[0])

	def set_standard(arr: List[str]):
		global cc

		if len(arr) != 1:
			raise ValueError("For executable name there's should be exactly one value")

		cc.set_standard(arr[0])

	def add_compile_flags(arr: List[str]):
		global cc

		for a in arr:
			cc.add_compile_flag(a)

	def add_linkage_flags(arr: List[str]):
		global cc

		for a in arr:
			cc.add_link_flag(a)

	for i in range(1, len(sys.argv)):
		arg = CMDElement(sys.argv[i])
		flag = arg.get_flag()
		vals = arg.get_values()
		match flag:
			case "include-libraries": include_libraries(vals)
			case "link-libraries": link_libraries(vals)
			case "build-type": build_type(vals)
			case "use-sanitizer": use_sanitizer(vals)
			case "name": set_name(vals)
			case "std": set_standard(vals)
			case "add-compile-flags": add_compile_flags(vals)
			case "add-linkage-flags": add_linkage_flags(vals)
			case _: raise NotImplementedError("Flag \"%s\" is not supported" % (flag))

	cc.add_sources(sources)
	if os.path.exists("include"):
		cc.include_headers("include", False)

	## Run compilation.

	command = cc.get_command()
	print(" ".join(command))
	exit(subprocess.run(command).returncode)
