xquery version "3.0";
let $Bank := doc("/db/a3/a3.xml")/Banking
let $auth:=
<auth>
    {
    for 
        $person in $Bank//Person,
        $card in $Bank//Card,
        $authrized in $card//Authorized
    where
        $person/Id=$authrized
    return 
        <authuser>
            {$person/Id}
            {$card/Id}
        </authuser>
    }

    {
    for 
        $person in $Bank//Person,
        $org in $Bank//Org,
        $signer in $org//Signer,
        $card in $Bank//Card
    where
        $person/Id=$signer 
        and $org/Id=$card/Owner
    return 
        <authuser>
            {$person/Id}
            {$card/Id}
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
                $signPerson/Id=$signer
                and $org/Id=$card/Owner
                and $user/Id=$auth
                and ($card/Limit - $card/Balance) < 1000
            return
                <pair>
                    <user>
                        {$user/Id}
                        {$user/Name}
                    </user>
                    <signer>
                        {$signPerson/Id} 
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
                $authorized := $auth//authuser[Id=$person/Id]
            where
                count($authorized) >2
                and count($person/PersonCards) > 3
            return
                <user>
                    {$person/Id}
                    {$person/Name}
                </user>
            }
        </query2>
        <query3>
    {
                
        for $card in $Bank//Card,
            $org in $Bank//Org
        where $card/Owner=$org/Id
            and (every $signer in $org/Signer satisfies
                exists( for $card1 in $Bank//Card
                        where $signer=$card1/Owner
                            and $card1/Limit >=25000
                        return $card1/Id)
                )
        return
            <result>{$card/Id}</result>
    }
        
    </query3>
    </answer>
     
    
  