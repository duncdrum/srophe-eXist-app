xquery version "3.0";
(:~
 : @depreciated: use /srophe/places/atom.xql 
 :)
import module namespace config="http://syriaca.org//config" at "config.xqm";

declare namespace xslt="http://exist-db.org/xquery/transform";
declare namespace tei="http://www.tei-c.org/ns/1.0";
declare namespace atom="http://www.w3.org/2005/Atom";
declare namespace xlink = "http://www.w3.org/1999/xlink";
declare namespace transform="http://exist-db.org/xquery/transform";
declare namespace request="http://exist-db.org/xquery/request";

declare variable $id {request:get-parameter('id', '')};

declare option exist:serialize "method=xml media-type=text/xml omit-xml-declaration=no indent=yes";

let $placeid := concat('place-',$id)
for $recs in collection($config:app-root || "/data/places/tei")/id($placeid)
let $rec := $recs/ancestor::tei:TEI
return $rec