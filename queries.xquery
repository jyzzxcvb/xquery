xquery version "3.0";
let $Bank := doc("/db/a3/a3.xml")/Banking
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
                <user>{$user/Id} {$user/Name}</user>
                <signer>{$signPerson/Id} {$signPerson/Name}</signer>
                </pair>
        }
     </query1>
     <query2>
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
                <user>{$user/Id} {$user/Name}</user>
                <signer>{$signPerson/Id} {$signPerson/Name}</signer>
                </pair>
        }
     </query2>
     </answer>
     
    
  