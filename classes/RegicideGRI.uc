class RegicideGRI extends AOCTDGRI;

simulated function string RetrieveObjectiveTitle(EAOCFaction Faction)
{
	return Localize("Regicide", "ObjectiveName" ,"Regicide");
}

simulated function string RetrieveObjectiveDescription(EAOCFaction Faction)
{
	return Localize("Regicide", "ObjectiveDescription", "Regicide");
}

simulated function string RetrieveObjectiveStatusText(EAOCFaction Faction)
{
	return "";
}