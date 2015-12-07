xquery version "3.0";
(: CSE532 -- Project 3 :)
(: File name: query3.xquery :)
(: Author: Jiayao Zhang (SBU Id 110369592) :)
(: Brief description: This file contains xquery for query 3:
Find the credit cards (acct. numbers) all of whose signers (i.e., people with signature authority
of the organizations that own those cards) also own personal credit cards with credit limits at
least $25,000. This query must use quantifiers.:)

declare default element namespace "http://localhost:8080/exist/apps/assignment3";
let $Bank := doc("/db/apps/assignment3/a3.xml")/Banking

return
<query3>
    {
                
        for $card in $Bank//Card,
            $org in $Bank//Org
        where $card/Owner=$org/OId
            and (every $signer in $org/Signer satisfies
                exists( for $card1 in $Bank//Card
                        where $signer=$card1/Owner
                            and $card1/Limit >=25000
                        return $card1/CId)
                )
        return
            <result>{$card/CId}</result>
    }
        
    </query3>