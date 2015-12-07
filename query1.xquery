xquery version "3.0";
(: CSE532 -- Project 3 :)
(: File name: query1.xquery :)
(: Author: Jiayao Zhang (SBU Id 110369592) :)
(: Brief description: This file contains xquery for query 1:
Find all pairs of the form (user,signer), where user is an authorized user of an organization's
credit card, signer is a person at that organization with signature authority, and the balance
on the card is within $1,000 of the credit limit. For each user/signer, show Id and Name (see
the expected output for an example).:)

(:I pledge my honor that all parts of this project were done by me alone and
without collaboration with anybody else.:)

declare default element namespace "http://localhost:8080/exist/apps/assignment3";

let $Bank := doc("/db/apps/assignment3/a3.xml")/Banking

return
        <query1>
            {
            for 
                $org in $Bank//Org,
                $user in $Bank//Person,
                $signPerson in $Bank//Person,
                $card in $Bank//Card,
                $signer in $org//Signer,
                $auth in $card//Authorized
            where
                $signPerson/PId=$signer
                and $org/OId=$card/Owner
                and $user/PId=$auth
                and ($card/Limit - $card/Balance) < 1000
            return
                <pair>
                    <user>
                        {$user/PId}
                        {$user/Name}
                    </user>
                    <signer>
                        {$signPerson/PId} 
                        {$signPerson/Name}
                    </signer>
                </pair>
            }
        </query1>