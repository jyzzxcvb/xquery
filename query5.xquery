xquery version "3.0";
(: CSE532 -- Project 3 :)
(: File name: query5.xquery :)
(: Author: Jiayao Zhang (SBU Id 110369592) :)
(: Brief description: This file contains xquery for query 5:
Find the total of all balances for the credit cards that have Joe as one of the indirect users. This
query can (and should) reuse some of the earlier queries.:)

(:I pledge my honor that all parts of this project were done by me alone and
without collaboration with anybody else.:)

declare default element namespace "http://localhost:8080/exist/apps/assignment3";

declare function local:indirectuser($indirect as element()*) as element()*
{
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
    let $direct:=
        <directusers>
            {
            for $auth in  $auth//authuser
            return
                <direct>
                    {$auth/PId}
                    {$auth/CId}
                </direct>
            }
        </directusers>
    let $moreIndirect:=
    for $u in $direct//direct,
        $i in $indirect//indirect,
        $p in $Bank//Person,
        $pc in $p/PersonCards
    where $u/CId=$pc
    and $i/PId=$p/PId
    return 
        <indirect>
            {$u/PId}
            {$i/CId}
        </indirect>
     
     
    let $directI:=
    for $d in $direct//direct
    return 
        <indirect>
            {$d/PId}
            {$d/CId}
        </indirect>
   
   
    let $unionDI:=  <a>{$moreIndirect union $directI}</a>
    
    let $distinct:=
    for $d in distinct-values($unionDI//indirect/PId),
    $c in distinct-values($unionDI//indirect[PId = $d]/CId)
    return 
        <indirect>
            <PId>{$d}</PId>
            <CId>{$c}</CId>
        </indirect>
  
    return
        if (count($distinct)>count($indirect//indirect))
        then
            local:indirectuser(<indirectusers>{$distinct}</indirectusers>)
        else
            $distinct
         
};

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


<query5>
        {
            let $query4:=
            <a>{
                let $i:=
                <indirectusers>
                    {
                        for $a in  $auth//authuser
                        return
                            <indirect>
                                {$a/PId}
                                {$a/CId}
                            </indirect>
                    }
                </indirectusers>
            let $allIndirect:=<allIndirect>{local:indirectuser($i)}</allIndirect>
            return  
            for $x in $allIndirect//indirect
            order by xs:string($x/PId)
            return
                <result>
                    {$x/PId}
                    {$x/CId}
                </result>
            }</a>
                
                
            let $cardBalance:=  
            for $c in $Bank//Card
            return
                for$i in $query4/result,
                    $p in $Bank//Person
                where $p/PId = $i/PId and
                    $c/CId = $i/CId and
                    $p/Name = "Joe"
                return $c/Balance
                
            return 
                <result>{sum($cardBalance)}</result>

        }
                    
    </query5>