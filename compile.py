import os
import sys
import subprocess
import yaml

from typing import List, Dict

## Utils.

class CMDElement:
	def __init__(self, x: str):
		xs = x.split("=")
		if len(xs) != 2:
			raise ValueError("String for CMDElement should have format as \"--<flag>=<value>\"")
		self.__CMDElement_flag = xs[0]
		if self.__CMDElement_flag.startswith("--"):
			self.__CMDElement_flag = self.__CMDElement_flag[2:]
		else:
			raise ValueError("Flag for CMDElement should have format as \"--<char sequence>\"")
		self.__CMDElement_values = xs[1].split(",")

	def get_flag(self) -> str:
		return self.__CMDElement_flag

	def get_values(self) -> List[str]:
		return self.__CMDElement_values

class Library:
	def __init__(self, parsed: Dict[str, str]):
		self.__Library_name = self.__Library_get_from("name", parsed)
		self.__Library_includedir = self.__Library_parsed_dir(self.__Library_get_from("includedir", parsed), "includedir")
		self.__Library_librarydir = self.__Library_parsed_dir(self.__Library_get_from("librarydir", parsed), "librarydir")

	@staticmethod
	def __Library_get_from(n: str, d: Dict[str, str]) -> str:
		if not n in d:
			raise LookupError("In library settings there must be \"%s\" option" % (n))
		return d[n]

	@staticmethod
	def __Library_parsed_dir(d: str, d_name: str) -> str:
		asenv = os.getenv(d)
		if asenv is None:
			if not os.path.exists(d):
				raise FileNotFoundError("Provided path and env-as-path \"%s\" as %s not exists" % (d, d_name))
			return d
		else:
			if not os.path.exists(asenv):
				raise FileNotFoundError("Provided \"%s\" as %s not exists" % (asenv, d_name))
			return asenv

	def name(self) -> str:
		return self.__Library_name

	def includedir(self) -> str:
		return self.__Library_includedir

	def librarydir(self) -> str:
		return self.__Library_librarydir

class CCBuilder:
	def __init__(self, is_cxx: bool, name_executable: str = None):
		self.__CCBuilder_is_cxx = is_cxx
		self.__CCBuilder_name_executable = name_executable
		self.__CCBuilder_std_flags = []
		self.__CCBuilder_bt_flags = []
		self.__CCBuilder_san_flags = []
		self.__CCBuilder_warn_flags = ["-Wall", "-Wextra", "-Wpedantic"]
		self.__CCBuilder_inc_flags = []
		self.__CCBuilder_src_flags = []
		self.__CCBuilder_lib_flags = []
		self.__CCBuilder_ld_flags = []

	def set_release(self):
		self.__CCBuilder_bt_flags = ["-O2"]

	def set_debug(self):
		self.__CCBuilder_bt_flags = ["-O0", "-g"]

	def set_sanitizer(self, name_sanitize: str):
		self.__CCBuilder_san_flags = ["-fno-sanitize-recover=all", "-fsanitize=" + name_sanitize]

	def set_name_executable(self, name_executable: str):
		self.__CCBuilder_name_executable = name_executable

	def set_standard(self, std: str):
		self.__CCBuilder_std_flags = ["--std=" + std]

	def include_headers(self, path_include: str, is_library: bool):
		if is_library:
			self.__CCBuilder_inc_flags.append("-isystem")
		else:
			self.__CCBuilder_inc_flags.append("-I")
		if not os.path.exists(path_include):
			raise ValueError("Provided path \"%s\" is not exists" % (path_include))
		self.__CCBuilder_inc_flags.append(path_include)

	def add_library(self, path_include: str):
		if not os.path.exists(path_include):
			raise ValueError("Provided path \"%s\" is not exists" % (path_include))
		self.__CCBuilder_lib_flags.append("-L")
		self.__CCBuilder_lib_flags.append(path_include)

	def add_source(self, path_source: str):
		if not os.path.exists(path_source):
			raise ValueError("Provided path \"%s\" is not exists" % (path_source))
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

		if len(self.__CCBuilder_bt_flags) == 0:
			raise ValueError("Command for compiling should be provided by buildtype")
		cmd += self.__CCBuilder_bt_flags

		if len(self.__CCBuilder_san_flags) != 0:
			cmd += self.__CCBuilder_san_flags

		cmd += self.__CCBuilder_warn_flags

		if len(self.__CCBuilder_inc_flags):
			cmd += self.__CCBuilder_inc_flags

		if len(self.__CCBuilder_src_flags) == 0:
			raise ValueError("No sources were provided to compile command")
		cmd += self.__CCBuilder_src_flags
	
		if len(self.__CCBuilder_lib_flags) != 0:
			cmd += self.__CCBuilder_lib_flags

		if self.__CCBuilder_name_executable is None:
			raise ValueError("Unknown executable name")

		cmd += ["-o", self.__CCBuilder_name_executable]

		if len(self.__CCBuilder_ld_flags) != 0:
			cmd += self.__CCBuilder_ld_flags

		return cmd

## Compile script.

DIRNAME_COMPILE_CONFIGS = ".compileconfig"

libs: Dict[str, Library] = {}

### Find and load compile script configs.

if not os.path.exists(DIRNAME_COMPILE_CONFIGS):
	print("[WARN] No %s directory found, no libraries loaded." % (DIRNAME_COMPILE_CONFIGS))
else:
	for f in os.listdir(DIRNAME_COMPILE_CONFIGS):
		p = os.path.join(DIRNAME_COMPILE_CONFIGS, f)
		stream = open(p, "r")
		lib = Library(yaml.safe_load(stream))
		libs[lib.name()] = lib

### Find sources.

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

### Build command.

cc = CCBuilder(is_cxx)

def include_library(arr: List[str]):
	global cc

	if len(arr) != 1:
		raise ValueError("For include-library flag there's should be exactly one value")

	a = arr[0]

	if not a in libs:
		raise ValueError("Library %s no found" % (a))

	cc.add_library(libs[a].librarydir())
	cc.include_headers(libs[a].includedir(), True)

def include_libraries(arr: List[str]):
	global cc

	for a in arr:
		if not a in libs:
			raise ValueError("Library %s no found" % (a))

		cc.add_library(libs[a].librarydir())
		cc.include_headers(libs[a].includedir(), True)

def link_library(arr: List[str]):
	global cc

	if len(arr) != 1:
		raise ValueError("For link-library flag there's should be exactly one value")

	cc.link_library(arr[0])

def link_libraries(arr: List[str]):
	global cc

	for a in arr:
		cc.link_library(a)

def build_type(arr: List[str]):
	global cc

	if len(arr) != 1:
		raise ValueError("For build-type flag there's should be exactly one value")

	a = arr[0]
	if a == "release":
		cc.set_release()
	elif a == "debug":
		cc.set_debug()
	else:
		raise ValueError("Unsupported buildtype (%s) found" % (a))

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

for i in range(1, len(sys.argv)):
	arg = CMDElement(sys.argv[i])
	flag = arg.get_flag()
	vals = arg.get_values()
	if flag == "include-library":
		include_library(vals)
	elif flag == "include-libraries":
		include_libraries(vals)
	elif flag == "link-library":
		link_library(vals)
	elif flag == "link-libraries":
		link_libraries(vals)
	elif flag == "build-type":
		build_type(vals)
	elif flag == "use-sanitizer":
		use_sanitizer(vals)
	elif flag == "name":
		set_name(vals)
	elif flag == "std":
		set_standard(vals)
	else:
		raise AttributeError("Flag \"%s\" not supported" % (arg.get_flag()))

cc.add_sources(sources)
if os.path.exists("include"):
	cc.include_headers("include", False)

### Run compilation.

print(" ".join(cc.get_command()))
subprocess.run(cc.get_command())
