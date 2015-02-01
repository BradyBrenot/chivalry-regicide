class RegicideGRI extends AOCTDGRI;

simulated function string RetrieveObjectiveTitle(EAOCFaction Faction)
{
	//return Localize("Regicide", "ObjectiveName" ,"Regicide");
	
	return "Regicide";
}

simulated function string RetrieveObjectiveDescription(EAOCFaction Faction)
{
	//return Localize("Regicide", "ObjectiveDescription", "Regicide");
	
	return "Protect your king, kill the enemy's!";
}

simulated function string RetrieveObjectiveStatusText(EAOCFaction Faction)
{
	return "";
}