class EmbyImageTag {
  EmbyImageTag() {}
  [string]$Primary
}

class EmbyPerson {
  EmbyPerson() {}
  [string]$Name
  [string]$ServerId
  [string]$Id
  [datetime]$DateCreated
  [string]$SortName
  [datetime]$PremiereDate
  [string]$Path
  [string]$Overview
  [string]$Type
  [EmbyImageTag]$ImageTags
  [EmbyImageTag[]]$BackdropImageTags
  [datetime]$EndDate
}