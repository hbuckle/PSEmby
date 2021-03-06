using System;
using System.Diagnostics;
using System.Text;

namespace PSEmby {
  public static class Process {
    public static ProcessResult Invoke(
      string FileName,
      string[] ArgumentList,
      string WorkingDirectory
    ) {
      var stderr = new StringBuilder();
      var stdout = new StringBuilder();
      var process = new System.Diagnostics.Process();
      process.StartInfo.FileName = FileName;
      foreach (string Argument in ArgumentList) {
        process.StartInfo.ArgumentList.Add(Argument);
      }
      process.StartInfo.CreateNoWindow = true;
      process.StartInfo.WorkingDirectory = WorkingDirectory;
      process.StartInfo.UseShellExecute = false;
      process.StartInfo.RedirectStandardOutput = true;
      process.StartInfo.RedirectStandardError = true;
      process.ErrorDataReceived += new DataReceivedEventHandler(
        (sender, e) => {
          if (!string.IsNullOrEmpty(e.Data)) {
            stderr.AppendLine(e.Data);
          }
        }
      );
      process.OutputDataReceived += new DataReceivedEventHandler(
        (sender, e) => {
          if (!string.IsNullOrEmpty(e.Data)) {
            stdout.AppendLine(e.Data);
          }
        }
      );
      process.Start();
      process.BeginErrorReadLine();
      process.BeginOutputReadLine();
      process.WaitForExit();
      return new ProcessResult()
      {
        ExitCode = process.ExitCode,
        StandardOutput = stdout.ToString(),
        StandardError = stderr.ToString(),
      };
    }
  }

  public class ProcessResult {
    public int ExitCode { get; set; }
    public string StandardOutput { get; set; }
    public string StandardError { get; set; }
  }
}
