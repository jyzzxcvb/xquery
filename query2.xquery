xquery version "3.0";
(: CSE532 -- Project 3 :)
(: File name: query2.xquery :)
(: Author: Jiayao Zhang (SBU Id 110369592) :)
(: Brief description: This file contains xquery for query 2:
Find all users (Id, Name) who own four or more cards and are authorized non-owner users for
three or more other cards. This query must use aggregates.:)

(:I pledge my honor that all parts of this project were done by me alone and
without collaboration with anybody else.:)

declare default element namespace "http://localhost:8080/exist/apps/assignment3";
let $Bank := doc("/db/apps/assignment3/a3.xml")/Banking
let $auth:=
<auth>
    {
    for 
        $person in $Bank//Person,
        $card in $Bank//Card,
        $authrized in $card//Authorized
    where
        $person/PId=$authrized
    return 
        <authuser>
            {$person/PId}
            {$card/CId}
        </authuser>
    }

    {
    for 
        $person in $Bank//Person,
        $org in $Bank//Org,
        $signer in $org//Signer,
        $card in $Bank//Card
    where
        $person/PId=$signer 
        and $org/OId=$card/Owner
    return 
        <authuser>
            {$person/PId}
            {$card/CId}
        </authuser>
    }
</auth>




return
<query2>
            {
            for 
                $person in $Bank//Person
            let
                $authorized := $auth//authuser[PId=$person/PId]
            where
                count($authorized) >2
                and count($person/PersonCards) > 3
            return
                <user>
                    {$person/PId}
                    {$person/Name}
                </user>
            }
        </query2>