// Representative excerpt from Scripts/NativeWindowIntegration.cs
// Native taskbar/background behavior for Windows, X11, and macOS.

using Godot;
using System;
using System.Runtime.InteropServices;

public partial class NativeWindowIntegration : Node
{
    private const int GwlExStyle = -20;
    private const long WsExToolWindow = 0x00000080L;
    private const long WsExAppWindow = 0x00040000L;
    private const int SwHide = 0;
    private const int SwShowNoActivate = 4;
    private const uint SwpNoMove = 0x0002;
    private const uint SwpNoSize = 0x0001;
    private const uint SwpNoZOrder = 0x0004;
    private const uint SwpNoActivate = 0x0010;
    private const uint SwpFrameChanged = 0x0020;
    private const int PropModeAppend = 2;

    public void ApplyAppBackgroundPolicy()
    {
        if (Godot.OS.GetName() != "macOS")
        {
            return;
        }

        try
        {
            ApplyMacOSAccessoryPolicy();
        }
        catch (Exception ex)
        {
            GD.PushWarning($"Unable to apply macOS background app policy: {ex.Message}");
        }
    }

    public void ApplyBackgroundWindowHints(int windowId)
    {
        if (windowId < 0)
        {
            return;
        }

        try
        {
            var windowHandle = new IntPtr(DisplayServer.WindowGetNativeHandle(DisplayServer.HandleType.WindowHandle, windowId));
            if (windowHandle == IntPtr.Zero)
            {
                return;
            }

            switch (Godot.OS.GetName())
            {
                case "Windows":
                    ApplyWindowsTaskbarSkip(windowHandle);
                    break;
                case "Linux":
                case "FreeBSD":
                case "NetBSD":
                case "OpenBSD":
                case "BSD":
                    ApplyX11TaskbarSkip(windowHandle, windowId);
                    break;
            }
        }
        catch (Exception ex)
        {
            GD.PushWarning($"Unable to hide window from taskbar: {ex.Message}");
        }
    }

    private static void ApplyWindowsTaskbarSkip(IntPtr hwnd)
    {
        var style = GetWindowLongPtr(hwnd, GwlExStyle).ToInt64();
        style &= ~WsExAppWindow;
        style |= WsExToolWindow;

        ShowWindow(hwnd, SwHide);
        SetWindowLongPtr(hwnd, GwlExStyle, new IntPtr(style));
        SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, SwpNoMove | SwpNoSize | SwpNoZOrder | SwpNoActivate | SwpFrameChanged);
        ShowWindow(hwnd, SwShowNoActivate);
        RemoveWindowsTaskbarTab(hwnd);
    }

    private static void RemoveWindowsTaskbarTab(IntPtr hwnd)
    {
        try
        {
            var taskbar = (ITaskbarList)new CTaskbarList();
            taskbar.HrInit();
            taskbar.DeleteTab(hwnd);
            if (OperatingSystem.IsWindows())
            {
                Marshal.ReleaseComObject(taskbar);
            }
        }
        catch
        {
            // The extended window style change above is the primary path.
        }
    }

    private static void ApplyX11TaskbarSkip(IntPtr windowHandle, int windowId)
    {
        var displayHandle = new IntPtr(DisplayServer.WindowGetNativeHandle(DisplayServer.HandleType.DisplayHandle, windowId));
        if (displayHandle == IntPtr.Zero)
        {
            return;
        }

        var wmState = XInternAtom(displayHandle, "_NET_WM_STATE", false);
        var atomType = XInternAtom(displayHandle, "ATOM", false);
        var skipTaskbar = XInternAtom(displayHandle, "_NET_WM_STATE_SKIP_TASKBAR", false);
        var skipPager = XInternAtom(displayHandle, "_NET_WM_STATE_SKIP_PAGER", false);
        if (wmState == IntPtr.Zero || atomType == IntPtr.Zero || skipTaskbar == IntPtr.Zero)
        {
            return;
        }

        ulong[] atoms = skipPager == IntPtr.Zero
            ? new[] { (ulong)skipTaskbar.ToInt64() }
            : new[] { (ulong)skipTaskbar.ToInt64(), (ulong)skipPager.ToInt64() };

        XChangeProperty(displayHandle, windowHandle, wmState, atomType, 32, PropModeAppend, atoms, atoms.Length);
        XFlush(displayHandle);
    }

    private static void ApplyMacOSAccessoryPolicy()
