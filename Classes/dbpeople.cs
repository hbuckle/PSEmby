using System;
using System.Text.RegularExpressions;
using System.Data.SQLite;
using System.Text;

namespace embymetadata
{
  public static class dbpeople
  {
    private static readonly string tablename = "MediaItems";
    private static readonly string persontype = "23";
    public static void setdbpersonid(string dbpath)
    {
      using (var connection = new SQLiteConnection($"Data Source={dbpath};Version=3;"))
      {
        connection.Open();
        connection.EnableExtensions(true);
        connection.LoadExtension("SQLite.Interop.dll", "sqlite3_fts5_init");
        var peoplequery = $"SELECT * FROM {tablename} WHERE type = '{persontype}' AND Name LIKE '% (%)' AND ProviderIds IS NULL";
        using (var peoplecommand = new SQLiteCommand(peoplequery, connection))
        {
          using (var people = peoplecommand.ExecuteReader())
          {
            while (people.Read())
            {
              var match = new Regex(@"\((\d+)\)", RegexOptions.Compiled);
              var matches = match.Matches(people["Name"].ToString());
              if (matches.Count == 1)
              {
                var tmdbid = matches[0].Value.Trim('(', ')');
                var providerid = $"Tmdb={tmdbid}";
                var guidbytes = new Guid(people["guid"].ToString()).ToByteArray();
                var guidstring = ByteArrayToString(guidbytes);
                var updatequery = $"UPDATE {tablename} SET ProviderIds = '{providerid}' WHERE guid = X'{guidstring}'";
                using (var updatecommand = new SQLiteCommand(updatequery, connection))
                {
                  var number = updatecommand.ExecuteNonQuery();
                }
              }
            }
          }
        }
      }
    }
    private static string ByteArrayToString(byte[] ba)
    {
      var hex = new StringBuilder(ba.Length * 2);
      foreach (byte b in ba)
        hex.AppendFormat("{0:x2}", b);
      return hex.ToString();
    }
  }
}