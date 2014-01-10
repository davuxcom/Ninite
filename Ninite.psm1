function Invoke-Ninite ($FilePath) {
    iex $FilePath
    Add-Type -MemberDefinition @"
	[DllImport("user32.dll")]
	public static extern int FindWindowEx(int parent, int childAfter, int cls, string title);
"@ -Name NativeMethods -Namespace Ninite -ErrorAction SilentlyContinue

    # Future: Reporting with Write-Progress based on the progress bar control
	$nin = 0
	write-host -NoNewline "Searching for Ninite process: "
	while ($nin -eq 0) {
		write-host -NoNewline "#"
        $nin = [Ninite.NativeMethods]::FindWindowEx(0, 0, 0, "Ninite")
		if ($nin -ne 0) {
			write-host -NoNewline "`n[Found] Waiting for complete: "
			$close = 0;
			while ($close -eq 0) {
                $close = [Ninite.NativeMethods]::FindWindowEx($nin, 0, 0, "Close")
				if ($close -eq 0) { sleep 1 }
				write-host -NoNewline "#"
			}
			write-host "`n[DONE]"
			kill -n ninite
			break
		} else {
			sleep 1
		}
	}
}

Export-ModuleMember -Function Invoke-Ninite