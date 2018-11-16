using System;
using System.Xml;
using System.Xml.Serialization;
using System.Text;
using System.IO;

namespace embymetadata
{
  [XmlTypeAttribute(AnonymousType = true)]
  public class director
  {
    [XmlTextAttribute]
    public string Value { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class actor
  {
    [XmlElementAttribute]
    public string name { get; set; }
    [XmlElementAttribute]
    public string role { get; set; }
    [XmlElementAttribute]
    public string type { get; set; }
    [XmlElementAttribute]
    public string thumb { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class resume
  {
    [XmlElementAttribute]
    public string position { get; set; }
    [XmlElementAttribute]
    public string total { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class art
  {
    [XmlElementAttribute]
    public string poster { get; set; }
    [XmlElementAttribute("fanart")]
    public fanart[] fanart { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class fanart
  {
    [XmlTextAttribute]
    public string Value { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class streamdetails
  {
    [XmlElementAttribute("video")]
    public video[] video { get; set; }
    [XmlElementAttribute("audio")]
    public audio[] audio { get; set; }
    [XmlElementAttribute("subtitle")]
    public subtitle[] subtitle { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class video
  {
    [XmlElementAttribute]
    public string codec { get; set; }
    [XmlElementAttribute]
    public string micodec { get; set; }
    [XmlElementAttribute]
    public string bitrate { get; set; }
    [XmlElementAttribute]
    public string width { get; set; }
    [XmlElementAttribute]
    public string height { get; set; }
    [XmlElementAttribute]
    public string aspect { get; set; }
    [XmlElementAttribute]
    public string aspectratio { get; set; }
    [XmlElementAttribute]
    public string framerate { get; set; }
    [XmlElementAttribute]
    public string language { get; set; }
    [XmlElementAttribute]
    public string scantype { get; set; }
    [XmlElementAttribute]
    public string @default { get; set; }
    [XmlElementAttribute]
    public string forced { get; set; }
    [XmlElementAttribute]
    public string duration { get; set; }
    [XmlElementAttribute]
    public string durationinseconds { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class audio
  {
    [XmlElementAttribute]
    public string codec { get; set; }
    [XmlElementAttribute]
    public string micodec { get; set; }
    [XmlElementAttribute]
    public string language { get; set; }
    [XmlElementAttribute]
    public string scantype { get; set; }
    [XmlElementAttribute]
    public string channels { get; set; }
    [XmlElementAttribute]
    public string samplingrate { get; set; }
    [XmlElementAttribute]
    public string @default { get; set; }
    [XmlElementAttribute]
    public string forced { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class subtitle
  {
    [XmlElementAttribute]
    public string codec { get; set; }
    [XmlElementAttribute]
    public string micodec { get; set; }
    [XmlElementAttribute]
    public string language { get; set; }
    [XmlElementAttribute]
    public string scantype { get; set; }
    [XmlElementAttribute]
    public string @default { get; set; }
    [XmlElementAttribute]
    public string forced { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  [XmlRootAttribute(Namespace = "", IsNullable = false)]
  public class movie
  {
    [XmlElementAttribute]
    public string plot { get; set; }
    [XmlElementAttribute]
    public string outline { get; set; }
    [XmlElementAttribute]
    public string lockdata { get; set; }
    [XmlElementAttribute]
    public string dateadded { get; set; }
    [XmlElementAttribute]
    public string title { get; set; }
    [XmlElementAttribute]
    public string year { get; set; }
    [XmlElementAttribute]
    public string sorttitle { get; set; }
    [XmlElementAttribute]
    public string tmdbid { get; set; }
    [XmlElementAttribute]
    public string id { get; set; }
    [XmlElementAttribute]
    public string runtime { get; set; }
    [XmlElementAttribute]
    public string isuserfavorite { get; set; }
    [XmlElementAttribute]
    public string playcount { get; set; }
    [XmlElementAttribute]
    public string watched { get; set; }
    [XmlElementAttribute]
    public string lastplayed { get; set; }
    [XmlElementAttribute("director")]
    public director[] director { get; set; }
    [XmlElementAttribute("actor")]
    public actor[] actor { get; set; }
    [XmlElementAttribute("resume")]
    public resume[] resume { get; set; }
    [XmlElementAttribute("art")]
    public art[] art { get; set; }
    [XmlArrayAttribute]
    [XmlArrayItemAttribute("streamdetails", typeof(streamdetails))]
    public streamdetails[] fileinfo { get; set; }

    public void Save(string Path)
    {
      var serializer = new XmlSerializer(typeof(movie), "");
      var xmlwritersettings = new XmlWriterSettings();
      xmlwritersettings.Indent = true;
      xmlwritersettings.NewLineOnAttributes = true;
      xmlwritersettings.Encoding = new UTF8Encoding(false);
      var namespaces = new XmlSerializerNamespaces();
      namespaces.Add("", "");
      using (var writer = XmlWriter.Create(Path, xmlwritersettings))
      {
        serializer.Serialize(writer, this, namespaces);
      }
    }
    public static movie Load(string Path)
    {
      var serializer = new XmlSerializer(typeof(movie), "");
      using (var reader = new StreamReader(Path))
      {
        return serializer.Deserialize(reader) as movie;
      }
    }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  [XmlRootAttribute(Namespace = "", IsNullable = false)]
  public class episodedetails
  {
    [XmlElementAttribute]
    public string plot { get; set; }
    [XmlElementAttribute]
    public string outline { get; set; }
    [XmlElementAttribute]
    public string lockdata { get; set; }
    [XmlElementAttribute]
    public string dateadded { get; set; }
    [XmlElementAttribute]
    public string title { get; set; }
    [XmlElementAttribute]
    public string year { get; set; }
    [XmlElementAttribute]
    public string sorttitle { get; set; }
    [XmlElementAttribute]
    public string id { get; set; }
    [XmlElementAttribute]
    public string runtime { get; set; }
    [XmlElementAttribute]
    public string isuserfavorite { get; set; }
    [XmlElementAttribute]
    public string playcount { get; set; }
    [XmlElementAttribute]
    public string watched { get; set; }
    [XmlElementAttribute]
    public string lastplayed { get; set; }
    [XmlElementAttribute]
    public string episode { get; set; }
    [XmlElementAttribute]
    public string season { get; set; }
    [XmlElementAttribute("director")]
    public director[] director { get; set; }
    [XmlElementAttribute("actor")]
    public actor[] actor { get; set; }
    [XmlElementAttribute("resume")]
    public resume[] resume { get; set; }
    [XmlElementAttribute("art")]
    public art[] art { get; set; }
    [XmlArrayAttribute]
    [XmlArrayItemAttribute("streamdetails", typeof(streamdetails))]
    public streamdetails[] fileinfo { get; set; }

    public void Save(string Path)
    {
      var serializer = new XmlSerializer(typeof(episodedetails), "");
      var xmlwritersettings = new XmlWriterSettings();
      xmlwritersettings.Indent = true;
      xmlwritersettings.NewLineOnAttributes = true;
      xmlwritersettings.Encoding = new UTF8Encoding(false);
      var namespaces = new XmlSerializerNamespaces();
      namespaces.Add("", "");
      using (var writer = XmlWriter.Create(Path, xmlwritersettings))
      {
        serializer.Serialize(writer, this, namespaces);
      }
    }
    public static episodedetails Load(string Path)
    {
      var serializer = new XmlSerializer(typeof(episodedetails), "");
      using (var reader = new StreamReader(Path))
      {
        return serializer.Deserialize(reader) as episodedetails;
      }
    }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  [XmlRootAttribute(Namespace = "", IsNullable = false)]
  public class tvshow
  {
    [XmlElementAttribute]
    public string plot { get; set; }
    [XmlElementAttribute]
    public string outline { get; set; }
    [XmlElementAttribute]
    public string lockdata { get; set; }
    [XmlElementAttribute]
    public string dateadded { get; set; }
    [XmlElementAttribute]
    public string title { get; set; }
    [XmlElementAttribute]
    public string tmdbid { get; set; }
    [XmlElementAttribute]
    public string season { get; set; }
    [XmlElementAttribute]
    public string episode { get; set; }
    [XmlElementAttribute]
    public string status { get; set; }
    [XmlElementAttribute("art")]
    public art[] art { get; set; }

    public void Save(string Path)
    {
      var serializer = new XmlSerializer(typeof(tvshow), "");
      var xmlwritersettings = new XmlWriterSettings();
      xmlwritersettings.Indent = true;
      xmlwritersettings.NewLineOnAttributes = true;
      xmlwritersettings.Encoding = new UTF8Encoding(false);
      var namespaces = new XmlSerializerNamespaces();
      namespaces.Add("", "");
      using (var writer = XmlWriter.Create(Path, xmlwritersettings))
      {
        serializer.Serialize(writer, this, namespaces);
      }
    }
    public static tvshow Load(string Path)
    {
      var serializer = new XmlSerializer(typeof(tvshow), "");
      using (var reader = new StreamReader(Path))
      {
        return serializer.Deserialize(reader) as tvshow;
      }
    }
  }
}