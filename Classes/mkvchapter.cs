using System;
using System.Xml;
using System.Xml.Serialization;
using System.Text;
using System.IO;

namespace Mkv {
  [XmlTypeAttribute(AnonymousType = true)]
  [System.Xml.Serialization.XmlRootAttribute(Namespace = "", IsNullable = false)]
  public class Chapters
  {
    [XmlElementAttribute("EditionEntry")]
    public EditionEntry[] EditionEntry { get; set; }

    public void Save(string Path)
      {
        var serializer = new XmlSerializer(typeof(Chapters), "");
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
      public static Chapters Load(string Path)
      {
        var serializer = new XmlSerializer(typeof(Chapters), "");
        using (var reader = new StreamReader(Path))
        {
          return serializer.Deserialize(reader) as Chapters;
        }
      }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class EditionEntry
  {
    [XmlElementAttribute]
    public string EditionFlagHidden { get; set; }
    [XmlElementAttribute]
    public string EditionFlagDefault { get; set; }
    [XmlElementAttribute]
    public string EditionUID { get; set; }
    [XmlElementAttribute("ChapterAtom")]
    public ChapterAtom[] ChapterAtom { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class ChapterAtom
  {
    [XmlElementAttribute]
    public string ChapterUID { get; set; }
    [XmlElementAttribute]
    public string ChapterTimeStart { get; set; }
    [XmlElementAttribute]
    public string ChapterFlagHidden { get; set; }
    [XmlElementAttribute]
    public string ChapterFlagEnabled { get; set; }
    [XmlElementAttribute("ChapterDisplay")]
    public ChapterDisplay[] ChapterDisplay { get; set; }
  }

  [XmlTypeAttribute(AnonymousType = true)]
  public class ChapterDisplay
  {
    [XmlElementAttribute]
    public string ChapterString { get; set; }
    [XmlElementAttribute]
    public string ChapterLanguage { get; set; }
  }
}