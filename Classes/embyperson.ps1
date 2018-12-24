class EmbyImageTag {
  EmbyImageTag() {}
  [string]$Primary
}

class EmbyPerson {
  EmbyPerson() {}
  [string]$Name
  [string]$ServerId
  [string]$Id
  [datetime]$PremiereDate
  [string]$Type
  [EmbyImageTag]$ImageTags
  [EmbyImageTag[]]$BackdropImageTags
  [datetime]$EndDate
}