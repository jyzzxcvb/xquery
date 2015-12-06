xquery version "3.0";
declare function local:indirectuser($indirect as element()*) as element()*
{
    let $Bank := doc("/db/a3/a3.xml")/Banking
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

let $Bank := doc("/db/a3/a3.xml")/Banking
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
    <answer>
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
        <query2>
            {
            for 
                $person in $Bank//Person
            let
                $authorized := $auth//authuser[Id=$person/PId]
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
    <query4>
        {
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

        }
           
       
    </query4>
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
    </answer>
     
    
  