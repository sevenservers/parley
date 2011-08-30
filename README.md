# Parley

> Parley. I invoke the right of parley. According to the Code of the Brethren, set down by the pirates Morgan and Bartholomew, you have to take me to your Captain.
> - Elizabeth

## Introduction
Parley is client software for a seedbox interface.  Once installed and run, it will relay the contents of the directory requested by the user through the service interface.

## Prerequisites
1. ruby >= 1.8.7 `ruby -v`
2. git (for updating)
3. bundler `gem install bundler`
4. static IP (for the Beta)
5. web server for static content (for the Beta)

## Spec
Sinatra & Thin running as a daemon

### API
    GET /directory/*path/.html
Returns non-recursive directory list in JSON.  Includes lastmtime, filesize.

    GET /directory/*path/.zip
Creates a zip archive and returns the url to the archive.    
    
    GET /stats/diskuse
Returns current disk use of the downloads folder

    GET /settings
Follow Symlinks (bool), Client API Key
  
    PUT /settings
Allows user to set settings from the service

### Authentication Scheme (Beta only, release should use OAuth)
User has API Key on service, client has API Key. Make em match.

## Proposed Release Features
* OAuth 
* Multiple user support
* Initiate an update from the service
* Update service with current IP (Removes static IP requirement)
* Stream data (Removes web server requirement)
* Package as a Ruby Gem
* SSL