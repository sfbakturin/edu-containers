import os
import sys
import subprocess
import yaml
import shutil

from typing import List, Dict, Optional
from abc import ABC, abstractmethod
from enum import Enum

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
		self.__binary_directory = self.__get_from("binarydir", parsed, False)
		if self.__binary_directory:
			self.__binary_directory = self.__parsed_directory(self.__binary_directory, "binarydir", False)

	@staticmethod
	def __get_from(n: str, d: Dict[str, str], fail_on_not_found: bool = True) -> str:
		if not n in d:
			if fail_on_not_found:
				raise LookupError("In library settings there must be \"%s\" option" % (n))
			else:
				return None
		return d[n]

	@staticmethod
	def __parsed_directory(d: str, d_name: str, fail_on_not_found: bool = True) -> str:
		asenv = os.getenv(d)
		if asenv is None:
			if not os.path.exists(d) and fail_on_not_found:
				raise FileNotFoundError("Provided path and env-as-path \"%s\" as %s not exists" % (d, d_name))
			elif not os.path.exists(d):
				return None
			return d
		else:
			if not os.path.exists(asenv) and fail_on_not_found:
				raise FileNotFoundError("Provided \"%s\" as %s not exists" % (asenv, d_name))
			elif not os.path.exists(asenv):
				return None
			return asenv

	def get_name(self) -> str:
		return self.__name

	def get_include(self) -> str:
		return self.__include_directory

	def get_library(self) -> str:
		return self.__library_directory

	def get_binary(self) -> str:
		if self.__binary_directory is None:
			raise ValueError("Attempt to get non existing binary directory")
		return self.__binary_directory

class Target(Enum):
	LINUX = 0
	WINDOWS = 1

def str2target(s: str) -> Target:
	name = s.lower()
	if name == 'windows':
		return Target.WINDOWS
	elif name == 'linux':
		return Target.LINUX
	else:
		raise ValueError('Unsupported defined operating system \"%s\" found' % (s))

def target2str(t: Target) -> str:
	match t:
		case Target.LINUX:
			return 'Linux'
		case Target.WINDOWS:
			return 'Windows'

class Profile(Enum):
	RELEASE = 0
	DEBUG = 1
	ADDRESS_SANITIZED = 2
	LEAK_SANITIZED = 3
	UNDEFINED_BEHAVIOR_SANITIZED = 4
	THREAD_SANITIZED = 5
	MEMORY_SANITIZED = 6

def str2profile(s: str) -> Profile:
	match s:
		case 'Release': return Profile.RELEASE
		case 'Debug': return Profile.DEBUG
		case 'AddressSanitized': return Profile.ADDRESS_SANITIZED
		case 'LeakSanitized': return Profile.LEAK_SANITIZED
		case 'UndefinedBehaviorSanitized': return Profile.UNDEFINED_BEHAVIOR_SANITIZED
		case 'ThreadSanitized': return Profile.THREAD_SANITIZED
		case _: raise ValueError('Unsupported compile profile \"%s\" found' % (s))

class STD(Enum):
	CC99 = 0
	CC11 = 1
	CC17 = 2
	CC23 = 3
	CXX11 = 4
	CXX14 = 5
	CXX17 = 6
	CXX20 = 7
	CXX23 = 8

def str2std(s: str) -> STD:
	match s:
		case 'c99': return STD.CC99
		case 'c11': return STD.CC11
		case 'c17': return STD.CC17
		case 'c23': return STD.CC23
		case 'c++11': return STD.CXX11
		case 'c++14': return STD.CXX14
		case 'c++17': return STD.CXX17
		case 'c++20': return STD.CXX20
		case 'c++23': return STD.CXX23
		case _: raise ValueError('Unsupported C/C++ standard \"%s\" found' % (s))

def std2str(s: str) -> STD:
	match s:
		case STD.CC99: return 'c99'
		case STD.CC11: return 'c11'
		case STD.CC17: return 'c17'
		case STD.CC23: return 'c23'
		case STD.CXX11: return 'c++11'
		case STD.CXX14: return 'c++14'
		case STD.CXX17: return 'c++17'
		case STD.CXX20: return 'c++20'
		case STD.CXX23: return 'c++23'

# Compilers.

class Compiler:
	def __init__(self, target: Target):
		self.__target = target

	def target(self) -> Target:
		return self.__target

	@abstractmethod
	def use_profile(self, profile: Profile):
		pass

	@abstractmethod
	def set_standard(self, std: STD):
		pass

	@abstractmethod
	def add_source(self, filename: str):
		pass

	@abstractmethod
	def add_sources(self, filenames: List[str]):
		pass

	@abstractmethod
	def add_include(self, dirname: str):
		pass

	@abstractmethod
	def add_libpath(self, dirname: str):
		pass

	@abstractmethod
	def as_dynamic(self):
		pass

	@abstractmethod
	def link_library(self, libname: str):
		pass

	@abstractmethod
	def finalize(self, outname: str, cxx: bool) -> List[str]:
		pass

class ClangCompiler(Compiler):
	__FORMAT_FLAG = '-%s'
	__FORMAT_VALUE = '%s%s%s'

	def __init__(self, target: Target):
		super().__init__(target)
		self.__defines: List[str] = []
		self.__standard: str = None
		self.__optimizations: List[str] = []
		self.__warnings: List[str] = []
		self.__sanitizers: List[str] = []
		self.__additional_compile_flags: List[str] = []
		self.__sources: List[str] = []
		self.__includes: List[str] = []
		self.__libpaths: List[str] = []
		self.__additional_linkage_flags: List[str] = []
		self.__libs: List[str] = []
		self.__initialize()

	def __initialize(self):
		# Check compiler compatibility.
		if self.target() != Target.LINUX:
			raise NotImplementedError('Clang compiler is supported only on Linux yet')

		# Set to Clang max warning level.
		self.__warnings = ['Wall', 'Wextra', 'Wpedantic']

	def use_profile(self, profile: Profile):
		match profile:
			case Profile.RELEASE:
				# Generate optimized code.
				self.__optimizations = ['O2']
			case Profile.DEBUG:
				# Generate code with debug information.
				self.__optimizations = ['O0']
			case _:
				# Generate code with even more debug information.
				self.__optimizations = ['O0', '-g']
				# Set sanitizer.
				if profile == Profile.ADDRESS_SANITIZED:
					self.__sanitizers = ['address']
				elif profile == Profile.LEAK_SANITIZED:
					self.__sanitizers = ['leak']
				elif profile == Profile.UNDEFINED_BEHAVIOR_SANITIZED:
					self.__sanitizers = ['undefined']
				elif profile == Profile.THREAD_SANITIZED:
					self.__sanitizers = ['thread']
				else:
					self.__sanitizers = ['memory']
					self.__additional_compile_flags = ['fPIE']
					self.__additional_linkage_flags = ['pie']

	def set_standard(self, std: STD):
		self.__standard = std2str(std)

	def add_source(self, filename: str):
		if not os.path.exists(filename):
			raise ValueError('File \"%s\" is not exists' % (filename))
		self.__sources.append(filename)

	def add_sources(self, filenames: List[str]):
		for p in filenames:
			self.add_source(p)

	def add_include(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__includes.append(dirname)

	def add_libpath(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__libpaths.append(dirname)

	def as_dynamic(self):
		raise NotImplementedError("Link libraries is not supported for Clang yet")

	def link_library(self, libname: str):
		self.__libs.append(libname)

	def finalize(self, outname: str, cxx: bool) -> List[str]:
		def fmt(flag: str, value: Optional[str] = None, sep: str = ' ') -> str:
			prefix = self.__FORMAT_FLAG % (flag)
			if value is None: return prefix
			return self.__FORMAT_VALUE % (prefix, sep, value)

		cmd: List[str] = []

		if cxx: cmd = ['clang++']
		else: cmd = ['clang']

		for define in self.__defines:
			cmd.append(fmt('D', define, ''))

		if self.__standard:
			cmd.append(fmt('std', self.__standard, '='))

		for optimization in self.__optimizations:
			cmd.append(fmt(optimization))

		for warning in self.__warnings:
			cmd.append(fmt(warning))

		for sanitizer in self.__sanitizers:
			cmd.append(fmt('fsanitize', sanitizer, '='))

		for compile_flag in self.__additional_compile_flags:
			cmd.append(fmt(compile_flag))

		for source in self.__sources:
			cmd.append(source)

		for include in self.__includes:
			cmd.append(fmt('I', include))

		for lib_path in self.__libpaths:
			cmd.append(fmt('L', lib_path))

		for linkage_flag in self.__additional_linkage_flags:
			cmd.append(fmt(linkage_flag))

		for lib in self.__libs:
			cmd.append(fmt('l', lib, ''))

		cmd.append(fmt('o', '\"' + outname + '\"'))

		return cmd

class GCCCompiler(Compiler):
	__FORMAT_FLAG = '-%s'
	__FORMAT_VALUE = '%s%s%s'

	def __init__(self, target: Target):
		super().__init__(target)
		self.__defines: List[str] = []
		self.__standard: str = None
		self.__optimizations: List[str] = []
		self.__warnings: List[str] = []
		self.__sanitizers: List[str] = []
		self.__sources: List[str] = []
		self.__includes: List[str] = []
		self.__libpaths: List[str] = []
		self.__libs: List[str] = []
		self.__initialize()

	def __initialize(self):
		# Check compiler compatibility.
		if self.target() != Target.LINUX:
			raise ValueError('GCC is available only on Linux')

		# Set to GCC max warning level.
		self.__warnings = ['Wall', 'Wextra', 'Wpedantic']

	def use_profile(self, profile: Profile):
		match profile:
			case Profile.RELEASE:
				# Generate optimized code.
				self.__optimizations = ['O2']
			case Profile.DEBUG:
				# Generate code with debug information.
				self.__optimizations = ['O0']
			case _:
				# Generate code with even more debug information.
				self.__optimizations = ['O0', '-g']
				# Set sanitizer.
				if profile == Profile.ADDRESS_SANITIZED:
					self.__sanitizers = ['address']
				elif profile == Profile.LEAK_SANITIZED:
					self.__sanitizers = ['leak']
				elif profile == Profile.UNDEFINED_BEHAVIOR_SANITIZED:
					self.__sanitizers = ['undefined']
				elif profile == Profile.THREAD_SANITIZED:
					self.__sanitizers = ['thread']
				else:
					raise ValueError('Unsupported sanitizer found')

	def set_standard(self, std: STD):
		self.__standard = std2str(std)

	def add_source(self, filename: str):
		if not os.path.exists(filename):
			raise ValueError('File \"%s\" is not exists' % (filename))
		self.__sources.append(filename)

	def add_sources(self, filenames: List[str]):
		for p in filenames:
			self.add_source(p)

	def add_include(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__includes.append(dirname)

	def add_libpath(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__libpaths.append(dirname)

	def as_dynamic(self):
		raise NotImplementedError("Link libraries is not supported for GCC yet")

	def link_library(self, libname: str):
		self.__libs.append(libname)

	def finalize(self, outname: str, cxx: bool) -> List[str]:
		def fmt(flag: str, value: Optional[str] = None, sep: str = ' ') -> str:
			prefix = self.__FORMAT_FLAG % (flag)
			if value is None: return prefix
			return self.__FORMAT_VALUE % (prefix, sep, value)

		cmd: List[str] = []

		if cxx: cmd = ['g++']
		else: cmd = ['gcc']

		for define in self.__defines:
			cmd.append(fmt('D', define, ''))

		if self.__standard:
			cmd.append(fmt('std', self.__standard, '='))

		for optimization in self.__optimizations:
			cmd.append(fmt(optimization))

		for warning in self.__warnings:
			cmd.append(fmt(warning))

		for sanitizer in self.__sanitizers:
			cmd.append(fmt('fsanitize', sanitizer, '='))

		for source in self.__sources:
			cmd.append(source)

		for include in self.__includes:
			cmd.append(fmt('I', include))

		for lib_path in self.__libpaths:
			cmd.append(fmt('L', lib_path))

		for lib in self.__libs:
			cmd.append(fmt('l', lib, ''))

		cmd.append(fmt('o', outname))

		return cmd

class MSVCCompiler(Compiler):
	__FORMAT_FLAG = '/%s'
	__FORMAT_VALUE = '%s%s%s'

	def __init__(self, target: Target):
		super().__init__(target)
		self.__defines: List[str] = []
		self.__standard: str = None
		self.__optimizations: List[str] = []
		self.__warnings: List[str] = []
		self.__stdlib: List[str] = []
		self.__sanitizers: List[str] = []
		self.__sources: List[str] = []
		self.__includes: List[str] = []
		self.__dynamic: List[str] = []
		self.__libpaths: List[str] = []
		self.__libs: List[str] = []
		self.__initialize()

	def __initialize(self):
		# Check compiler compatibility.
		if self.target() != Target.WINDOWS:
			raise ValueError('MSVC is available only on Windows')

		# No MSVC secure warnings.
		self.__defines.append('_CRT_SECURE_NO_WARNINGS')

		# Set to MSVC max warning level.
		self.__warnings.append('W4')

	def use_profile(self, profile: Profile):
		match profile:
			case Profile.RELEASE:
				# Generate optimized code.
				self.__optimizations = ['O2']
				# Use MSVC standard library.
				# FIXME: Maybe, we should choose between static/dynamic.
				self.__stdlib = ['MD']
			case Profile.DEBUG:
				# Generate code with debug information.
				self.__optimizations = ['Od']
				# Use MSVC standard library.
				# FIXME: Maybe, we should choose between static/dynamic.
				self.__stdlib = ['MDd']
			case Profile.ADDRESS_SANITIZED:
				# Generate code with even more debug information.
				self.__optimizations = ['Od', 'Z7']
				# Use MSVC standard library.
				# FIXME: Maybe, we should choose between static/dynamic.
				self.__stdlib = ['MDd']
				# Turn off any strange CL's ASan behavior.
				self.__defines = ['_DISABLE_VECTOR_ANNOTATION', '_DISABLE_STRING_ANNOTATION']
				# Set sanitizer.
				self.__sanitizers = ['address']
			case _:
				raise ValueError('On MSVC supported only Release, Debug and AddressSanitized profiles')

	def set_standard(self, std: STD):
		match std:
			case STD.CC99:
				raise ValueError('C99 is not supported by MSVC')
			case x:
				self.__standard = std2str(x)

	def add_source(self, filename: str):
		if not os.path.exists(filename):
			raise ValueError('File \"%s\" is not exists' % (filename))
		self.__sources.append(filename)

	def add_sources(self, filenames: List[str]):
		for p in filenames:
			self.add_source(p)

	def add_include(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__includes.append(dirname)

	def add_libpath(self, dirname: str):
		if not os.path.exists(dirname):
			raise ValueError('Directory \"%s\" is not exists' % (dirname))
		self.__libpaths.append(dirname)

	def as_dynamic(self):
		self.__dynamic = ['DYNAMICBASE']

	def link_library(self, libname: str):
		self.__libs.append(libname)

	def finalize(self, outname: str, _: bool) -> List[str]:
		def fmt(flag: str, value: Optional[str] = None, sep: str = ' ') -> str:
			prefix = self.__FORMAT_FLAG % (flag)
			if value is None: return prefix
			return self.__FORMAT_VALUE % (prefix, sep, value)

		if len(self.__optimizations) == 0:
			raise ValueError('Flag --use-profile is required')

		cmd: List[str] = ['cl', fmt('EHsc')]

		for define in self.__defines:
			cmd.append(fmt('D', define))

		if self.__standard:
			cmd.append(fmt('std', self.__standard, ':'))

		for optimization in self.__optimizations:
			cmd.append(fmt(optimization))

		for stdlib in self.__stdlib:
			cmd.append(fmt(stdlib))

		for warning in self.__warnings:
			cmd.append(fmt(warning))

		for sanitizer in self.__sanitizers:
			cmd.append(fmt('fsanitize', sanitizer, '='))

		for source in self.__sources:
			cmd.append(source)

		for include in self.__includes:
			cmd.append(fmt('I', include + '/'))

		cmd.append(fmt('link'))

		for lib_path in self.__libpaths:
			cmd.append(fmt('LIBPATH', lib_path + '/', ':'))

		for d in self.__dynamic:
			cmd.append(fmt(d))

		for lib in self.__libs:
			cmd.append(lib)

		cmd.append(fmt('OUT', outname, ':'))

		return cmd

def str2compiler(s: str, t: Target) -> Compiler:
	name = s.lower()
	if name == 'clang':
		return ClangCompiler(t)
	elif name == 'gcc':
		return GCCCompiler(t)
	elif name == 'msvc':
		return MSVCCompiler(t)
	else:
		raise ValueError('Unsupported compiler \"%s\" found' % (s))

# Environment.

EDU_PREFIX = 'EDUCONTAINER'

def envname(name: str) -> str:
	return "%s_%s" % (EDU_PREFIX, name.upper())

def getenv(name: str) -> str:
	name = envname(name)
	print('Checking for %s...' % (name))
	value = os.getenv(name)
	if value is None:
		raise ValueError('Environment variable \"%s\" must exist' % (name))
	print('Checking for %s... done.' % (name))
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
	print('[WARN] No \"%s\" directory found, no libraries loaded.' % (DIRNAME_COMPILE_CONFIGS))
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

target: Target = str2target(getenv('target_system'))
compiler: Compiler = str2compiler(getenv('target_name'), target)
as_msvc_dynamic_base: List[str] = []

name_executable = None

def include_libraries(cc: Compiler, arr: List[str]):
	for a in arr:
		if not a in libs:
			raise ValueError('Library \"%s\" not found in loader' % (a))
		cc.add_libpath(libs[a].get_library())
		cc.add_include(libs[a].get_include())

def link_libraries(cc: Compiler, arr: List[str]):
	for a in arr:
		cc.link_library(a)

def set_standard(cc: Compiler, arr: List[str]):
	if len(arr) != 1:
		raise ValueError('For using standard there\'s should be exactly one value')
	cc.set_standard(str2std(arr[0]))

def use_profile(cc: Compiler, arr: List[str]):
	if len(arr) != 1:
		raise ValueError('For using profile there\'s should be exactly one value')
	cc.use_profile(str2profile(arr[0]))

def as_dynamic(cc: Compiler, arr: List[str], dynamic_base: List[str]):
	cc.as_dynamic()
	for a in arr:
		if not a in libs:
			raise ValueError('Library \"%s\" not found in loader' % (a))
		dynamic_base.append(libs[a].get_binary())

for i in range(1, len(sys.argv)):
	arg = CMDElement(sys.argv[i])
	flag = arg.get_flag()
	vals = arg.get_values()
	match flag:
		case "name": name_executable = vals[0]
		case "include-libraries": include_libraries(compiler, vals)
		case "link-libraries": link_libraries(compiler, vals)
		case "std": set_standard(compiler, vals)
		case "use-profile": use_profile(compiler, vals)
		case "as-dynamic": as_dynamic(compiler, vals, as_msvc_dynamic_base)
		case _: raise NotImplementedError("Flag \"%s\" is not supported" % (flag))

compiler.add_sources(sources)
if os.path.exists('include'):
	compiler.add_include('include')

# FIXME: Looks like dirty...
def compile_as_windows(command: List[str], dynamic: List[str]):
	# TODO: Should be introduced in ENV.
	MSVC_SETUP = 'C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\VC\\Auxiliary\\Build\\vcvars64.bat'
	ERROR_BATCH = 'exit /b 666'
	with open('compile.bat', 'w') as script:
		current_working_directory = os.getcwd()
		for d in dynamic:
			if not os.path.exists(d):
				raise FileNotFoundError('Provided path with binaries \"%s\" not found' % (d))
			for f in os.listdir(d):
				p = os.path.join(d, f)
				if p.endswith(".dll"):
					n = os.path.join(current_working_directory, f)
					shutil.copyfile(p, n)
		script.write('call \"%s\"\n%s || %s\n' % (MSVC_SETUP, ' '.join(command), ERROR_BATCH))
	exit(subprocess.run(['compile.bat'], shell = True).returncode)

# FIXME: And this looks like dirty...
def compile_as_linux(command: List[str]):
	ERROR_BASH = 'exit 666'
	with open('compile.bash', 'w') as script:
		script.write('%s || %s\n' % (' '.join(command), ERROR_BASH))
	exit(subprocess.run(['bash', 'compile.bash']).returncode)

command = compiler.finalize(name_executable, is_cxx)
print(' '.join(command))

if target == Target.WINDOWS:
	compile_as_windows(command, as_msvc_dynamic_base)
compile_as_linux(command)
