﻿using System;
using System.Runtime.InteropServices;
using System.Text;

namespace XpandPwsh.Cmdlets.Gac{
    [ComImport]
    [InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
    [Guid("CD193BC0-B4BC-11d2-9833-00C04FC31D2E")]
    internal interface IAssemblyName{
        [PreserveSig]
        int SetProperty(
            int PropertyId,
            IntPtr pvProperty,
            int cbProperty);

        [PreserveSig]
        int GetProperty(
            AssemblyNameProperty PropertyId,
            IntPtr pvProperty,
            ref int pcbProperty);

        [PreserveSig]
        int Finalize();

        [PreserveSig]
        int GetDisplayName(
            StringBuilder pDisplayName,
            ref int pccDisplayName,
            AssemblyNameDisplayFlags displayFlags);

        [PreserveSig]
        int Reserved(ref Guid guid,
            object obj1,
            object obj2,
            string string1,
            long llFlags,
            IntPtr pvReserved,
            int cbReserved,
            out IntPtr ppv);

        [PreserveSig]
        int GetName(
            ref int pccBuffer,
            StringBuilder pwzName);

        [PreserveSig]
        int GetVersion(
            out int versionHi,
            out int versionLow);

        [PreserveSig]
        int IsEqual(
            IAssemblyName pAsmName,
            AssemblyCompareFlags cmpFlags);

        [PreserveSig]
        int Clone(out IAssemblyName pAsmName);
    }
}