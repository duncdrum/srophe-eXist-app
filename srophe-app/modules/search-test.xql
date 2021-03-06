xquery version "3.0";

import module namespace kwic="http://exist-db.org/xquery/kwic" at "resource:org/exist/xquery/lib/kwic.xql";
declare namespace util="http://exist-db.org/xquery/util";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace xlink = "http://www.w3.org/1999/xlink";

declare variable $q {request:get-parameter('q', '')};
declare variable $mode {request:get-parameter('mode', '')};
declare variable $p {request:get-parameter('p', '')};
declare variable $type {request:get-parameter('type', '')};

declare variable $loc {request:get-parameter('loc', '')};
declare variable $lat {request:get-parameter('lat', '')};
declare variable $long {request:get-parameter('long', '')};

declare variable $e {request:get-parameter('e', '')};
declare variable $e-start {request:get-parameter('e-start', '')};
declare variable $e-end {request:get-parameter('e-end', '')};

declare variable $a {request:get-parameter('a', '')};
declare variable $a-start {request:get-parameter('a-start', '')};
declare variable $a-end {request:get-parameter('a-end', '')};

declare variable $c {request:get-parameter('c', '')};
declare variable $c-start {request:get-parameter('c-start', '')};
declare variable $c-end {request:get-parameter('c-end', '')};

declare variable $exist {request:get-parameter('exist', '')};
declare variable $exist-start {request:get-parameter('exist-start', '')};
declare variable $exist-end {request:get-parameter('exist-end', '')};

declare variable $lang {request:get-parameter('lang', '')};

declare variable $start {request:get-parameter('start', 1) cast as xs:integer};

(:~
 : Build full-text keyword search over all tei:place data
 : @q full text query
:)
declare function local:keyword(){
    if(exists($q) and $q != '') then concat('[ft:query(.,"',$q,'")]')
    else ''    
};

(:~
 : Build full-text keyword search over all tei:placeName data
 : @p full text query
:)
declare function local:place-name(){
    if(exists($p) and $p != '') then concat('[ft:query(tei:placeName,"',$p,'")]')
    else ''    
};

(:~
 : Build range search on tei:place/@type data
 : @type full text query
:)
declare function local:type(){
    if(exists($type) and $type != '') then string(concat('[@type = "',$type,'"]'))
    else '' 
};

(:~
 : Build full-text search on tei:place/tei:location data
 : @loc full text query
 : NOTE: need to understand location search better. 
:)
declare function local:location(){
    if(exists($loc) and $loc != '') then concat('[ft:query(tei:location,"',$loc,'")]')
    else ''
};

(:~
 : Build full-text search on tei:event[@type != attestation] data
 NOTE: will probably have to build this into the date range, so they hold together as one AND predicate
 : @e full text query
:)
declare function local:event(){
    if(exists($e) and $e != '') then concat('[ft:query(tei:event[@type != "attestation" or not(@type)],"',$e,'")]')
    else ''
};

(:~
 : Build date range for event 
 : tei:event[@type != attestation]
 : @es event start range index
 : @ee event end range index
//tei:place[descendant::tei:state[@syriaca-computed-start gt "1000-01-01" and @syriaca-computed-end lt "1200-01-01"] or [@syriaca-computed-start gt "1000-01-01" and not(@syriaca-computed-end)]]
concat('[descendant::tei:event[@type != "attestation" or not(@type)][@syriaca-computed-start gt "',local:do-date($e-start),'" and @syriaca-computed-end lt "',local:do-date($e-end),'"]]')
:)
declare function local:event-dates(){
    if(exists($e-start) and $e-start != '') then 
        if(exists($e-end) and $e-end != '') then 
            concat('/descendant::tei:event[@type != "attestation" or not(@type)]
            [(
            @syriaca-computed-start gt 
                "',local:do-date($e-start),'" 
                and @syriaca-computed-end lt 
                "',local:do-date($e-end),'"
                ) or (
                @syriaca-computed-start gt 
                "',local:do-date($e-start),'" 
                and 
                not(exists(@syriaca-computed-end)))]')
        else 
            concat('/descendant::tei:event[@type != "attestation" or not(@type)][@syriaca-computed-start gt "',local:do-date($e-start),'"]')
    else if (exists($e-end) and $e-end != '') then 
        concat('/descendant::tei:event[@type != "attestation" or not(@type)][@syriaca-computed-end lt "',local:do-date($e-end),'" or @syriaca-computed-start lt "',local:do-date($e-end),'" and not(@syriaca-computed-end)]')
    else ''
};

(:~
 : Build full-text search on tei:event[@type = attestation] data
 : @e full text query
:)
declare function local:attestation(){
    if(exists($a) and $a != '') then concat('[ft:query(tei:event[@type = "attestation"],"',$a,'")]')
    else ''
};
(:~
 : Build date range for attestation
 : tei:event[@type = attestation]
 : @as attestation start range index
 : @ae attestation end range index
:)
declare function local:attestation-dates(){
    if(exists($a-start) and $a-start != '') then 
        if(exists($a-end) and $a-end != '') then 
             concat('[descendant::tei:event[@type != "attestation" or not(@type)][(@syriaca-computed-start gt "',local:do-date($e-start),'" and @syriaca-computed-end lt "',local:do-date($e-end),'") or (@syriaca-computed-start gt "',local:do-date($e-start),'" and not(@syriaca-computed-end))]]')
        else concat('[descendant::tei:event[@type = "attestation"][@syriaca-computed-start gt "',local:do-date($a-start),'"]]') 
    else if (exists($a-end) and $a-end != '') then 
        concat('[descendant::tei:event[@type = "attestation"][@syriaca-computed-end lt "',local:do-date($a-end),'"]]')
    else ''
};

(:~
 : Build full-text search on tei:state[@type = confession] data
 : @e full text query
:)
declare function local:confession(){
    if(exists($c) and $c != '') then concat('[ft:query(descendant::tei:state[@type = "confession"],"',$c,'")]')
    else ''
};
(:~
 : Build date range for confession
 : tei:state[@type = confession]
 : @as confession start range index
 : @ae confession end range index
:)
declare function local:confession-dates(){
    if(exists($c-start) and $c-start != '') then 
        if(exists($c-end) and $c-end != '') then 
            concat('[descendant::tei:state[@type = "confession"][@syriaca-computed-start gt "',local:do-date($c-start),'" and @syriaca-computed-end lt "',local:do-date($c-end),'"]]')
        else concat('[descendant::tei:state[@type = "confession"][@syriaca-computed-start gt "',local:do-date($c-start),'"]]') 
    else if (exists($c-end) and $c-end != '') then 
        concat('[descendant::tei:state[@type = "confession"][@syriaca-computed-end lt "',local:do-date($c-end),'"]]')
    else ''
};

declare function local:show-confession-dates(){
    if(exists($c-start) and $c-start != '') then 
        if(exists($c-end) and $c-end != '') then 
            concat('/descendant::tei:state[@type = "confession"][@syriaca-computed-start gt "',local:do-date($c-start),'" and @syriaca-computed-end lt "',local:do-date($c-end),'"]')
        else concat('/descendant::tei:state[@type = "confession"][@syriaca-computed-start gt "',local:do-date($c-start),'"]') 
    else if (exists($c-end) and $c-end != '') then 
        concat('/descendant::tei:state[@type = "confession"][@syriaca-computed-end lt "',local:do-date($c-end),'"]')
    else ''
};


(:~
 : Build full-text search on tei:state[@type = ‘existence’] data
 : @e full text query
:)
declare function local:existence(){
    if(exists($exist) and $exist != '') then concat('[ft:query(descendant::tei:state[@type = "confession"],"',$exist,'")]')
    else ''
};

(:~
 : Build date range for existence
 : tei:state[@type = existence]
 : @as confession start range index
 : @ae confession end range index
:)
declare function local:existence-dates(){
    if(exists($exist-start) and $exist-start != '') then 
        if(exists($exist-end) and $exist-end != '') then 
            concat('[descendant::tei:state[@type = "existence"][@syriaca-computed-start gt "',local:do-date($exist-start),'" and @syriaca-computed-end lt "',local:do-date($exist-end),'"]]')
        else concat('[descendant::tei:state[@type = "existence"][@syriaca-computed-start gt "',local:do-date($exist-start),'"]]') 
    else if (exists($exist-end) and $exist-end != '') then 
        concat('[descendant::tei:state[@type = "existence"][@syriaca-computed-end lt "',local:do-date($exist-end),'"]]')
    else ''
};

declare function local:show-existence-dates(){
    if(exists($exist-start) and $exist-start != '') then 
        if(exists($exist-end) and $exist-end != '') then 
            concat('/descendant::tei:state[@type = "existence"][@syriaca-computed-start gt "',local:do-date($exist-start),'" and @syriaca-computed-end lt "',local:do-date($exist-end),'"]')
        else concat('/descendant::tei:state[@type = "existence"][@syriaca-computed-start gt "',local:do-date($exist-start),'"]') 
    else if (exists($exist-end) and $exist-end != '') then 
        concat('/descendant::tei:state[@type = "existence"][@syriaca-computed-end lt "',local:do-date($exist-end),'"]')
    else ''
};

(:~
 : Function to cast date strings from url to xs:date
 :@param $date passed to function from parent function
:)
declare function local:do-date($date){
let $date-format := if(string-length($date) eq 4) then concat(string($date),'-01-01')
                          else if(string-length($date) eq 5) then concat(string($date),'-01-01')
                          else string($date)
let $final-date := xs:date($date-format) 
return $final-date
};


(:need some clarification on what exactly is being limited by lang?:)
declare function local:limit-by-lang(){
    if(exists($lang) and $lang != '') then concat('[descendant::*/@lang = "',$lang,'"]')
    else ''
};

declare function local:test-search(){
    for $hit in collection('/db/apps/srophe/data/places/tei')//tei:place
    let $id := substring-after($hit/@xml:id,'place-')
    order by ft:score($hit) descending
    return 
            <div class="result">
             <title>{$hit/tei:placeName[@syriaca-tags='#syriaca-headword'][@xml:lang='en']}</title>
             <state>{$hit/descendant::tei:state[@syriaca-computed-start gt "0723-01-01" and @syriaca-computed-end lt "1200-01-01"]}</state>
            </div>

};
declare function local:lang(){
        if(exists($lang) and $lang != '') then '[tei:placeName/@xml:lang="ar"]'
    else ''
};
(:~
 : Builds search query and results
 :
:)
declare function local:run-search(){
    let $eval-string := concat("collection('/db/apps/srophe/data/places/tei')//tei:place",
    local:keyword(),
    local:type(),
    local:place-name(),
    local:location(),
    local:lang(),
    local:event(),local:event-dates(),
    local:attestation(), local:attestation-dates(), 
    local:existence(),local:existence-dates(),
    local:confession(),local:confession-dates()
    )
    let $hits := util:eval($eval-string)    
    for $hit in $hits
    let $id := substring-after($hit/@xml:id,'place-')
    order by ft:score($hit) descending
    return 
            <div class="result">{$hit}</div>
};

let $cache := 'ddd'
let $eval-string := concat("collection('/db/apps/srophe/data/places/tei')//tei:place",
    local:keyword(),
    local:type(),
    local:place-name(),
    local:location(),local:lang(),
    local:event(),local:event-dates(),
    local:attestation(), local:attestation-dates(), 
    local:existence(),local:existence-dates(),
    local:confession(),local:confession-dates()
    )
return 
<div>
{
    local:run-search()
 }
</div>

    