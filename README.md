# wine-python
This builds a container image that runs the Windows version of CPython over wine


## Status 2025-10-29

Recent Python versions (e.g., 3.13+) require Windows 8+ APIs, including CopyFile2.
Wine defaults to Windows 7 compatibility, which lacks these APIs.
Python installers refuse to run on Wine unless Wine mimics Windows 8 or 10.
--
"""
"""
wine-python -m venv .venv
wine: Call from 00006FFFFFC7D3B8 to unimplemented function KERNEL32.dll.CopyFile2, aborting
wine: Unimplemented function KERNEL32.dll.CopyFile2 called at address 00006FFFFFC7D3B8 (thread 0114), starting debugger...
Couldn't get first exception for process 0110 C:\WinPython\WPy64-31700\python\python.exe.
No backtrace available
"""

=> Switched to debian Sid (has wine 10+)
