#-----------------------------------------------------------------------------#
#   basilisk.coffee                                                           #
#                                                                             #
#   Copyright (c) 2015, Seventy Four, Inc.                                    #
#   All rights reserved.                                                      #
#-----------------------------------------------------------------------------#



class Singleton
    @instance: (args...) ->
        @tmp ?= new @(args...)



class Util extends Singleton
    constructor: ->
        String::trimAll ?= ->
            s = @['trim']()
            s = s['replace'] /\s+/g, ' '

        String::isAlphaNumeric ?= ->
            regx = /^[0-9A-Za-z]+$/
            regx['test'] @

        Array::random ?= ->
            @[Math['floor'] Math['random']() * @['length']]

    injectScriptTag: (src, async = true, id = null, func = null) ->
        newScriptTag = createScriptTag src, async, id
        newScriptTag['onload'] = func unless func is null
        firstScriptTag = document['getElementsByTagName']('script')[0]
        firstScriptTag['parentNode']['insertBefore'] newScriptTag, firstScriptTag
        newScriptTag

    createScriptTag = (src, async = true, id = null) ->
        scriptTag = document['createElement'] 'script'
        scriptTag['type'] = 'text/javascript'
        scriptTag['async'] = async
        scriptTag['src'] = src
        scriptTag['id'] = id if id?
        scriptTag

    setCookie: (key, value, seconds = null) ->
        value = encodeURIComponent value
        if seconds?
            date = new Date
            date['setTime'] date['getTime']() + seconds * 1000
            expires = date['toUTCString']()
            document['cookie'] = "#{ key }=#{ value }; expires=#{ expires }"
        else
            document['cookie'] = "#{ key }=#{ value }"

    getCookie: (key) ->
        for cookie in document['cookie']['split'] ';'
            cookie = $['trim'] cookie
            if cookie['substring'](0, key['length'] + 1) == "#{ key }="
                return decodeURIComponent cookie['substring'] key['length'] + 1
        null

    preventRubberBand: ->
        $(document)['on'] 'touchmove', (eventObject) ->
            eventObject['preventDefault']()
            false



class GoogleAnalytics extends Singleton
    constructor: (webPropertyId, domain = 'auto') ->
        if webPropertyId?
            window['ga'] 'create', webPropertyId, domain
            window['ga'] 'require', 'displayfeatures'
            window['ga'] 'send', 'pageview'
            $('.external')['on'] 'click', externalLink
            true
        else
            false

    trackPageView: (url) ->
        window['ga'] 'send', 'pageview', url

    trackEvent: (category, action, label = null, value = null, nonInteraction = null) ->
        trackedEvent = 'hitType': 'event', 'eventCategory': category, 'eventAction': action
        if label? then trackedEvent['eventLabel'] = label
        if value? then trackedEvent['eventValue'] = value
        if nonInteraction? then trackedEvent['nonInteraction'] = nonInteraction
        window['ga'] 'send', trackedEvent

    externalLink: (href) ->
        window['open'] href, '_blank'
        GoogleAnalytics.instance().trackEvent 'Outbound Link', 'Click', href, null, true
        mixpanel['track'] 'Outbound Link Click'

    externalLink = (eventObject) ->
        href = eventObject['target']['href']
        GoogleAnalytics.instance().externalLink href
        false



class Invite extends Singleton
    $form = null

    constructor: ->
        $form = $ 'form'
        return false unless $form['length']
        $form['on'] 'submit', submit
        true

    submit = ->
        [users, classes] = [[], []]
        $(':checked')['each'] ->
            users['push'] $(@)['val']()
            classes['push'] ".#{ $(@)['attr'] 'class' }"
        $(classes['join'] ', ')['slideUp'] 400, ->
            unless $('label:visible')['length']
                $form['fadeOut'] 400, ->
                    $('#thank-you')['fadeIn']()
        $['post'] '/invite', 'users[]': users, null, 'json'
        false



$ ->
    Util.instance()
    GoogleAnalytics.instance 'UA-52100043-3', 'basilisk.us'
    Invite.instance()
