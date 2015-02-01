class RegicideAICombatController extends AOCAICombatController;

function NotifyChosenAsKing(class<AOCFamilyInfo> KingClass)
{
	local vehicle DrivenVehicle;
	
    DrivenVehicle = Vehicle(Pawn);
	if( DrivenVehicle != None )
		DrivenVehicle.DriverLeave(true);
	
	if(Pawn != none)
	{
		AOCPRI(PlayerReplicationInfo).Deaths -= 1;
		Pawn.TakeDamage(600, none, Location, Vect(0.0f, 0.0f, 0.0f), class'AOCDmgType_Generic');
	}
	
	RegicidePRI(PlayerReplicationInfo).bCurrentlyKing = true;
	RegicidePRI(PlayerReplicationInfo).CurrentKingFamily = AOCGRI(Worldinfo.GRI).GetOrSpawnFamilyInfoFromClass(KingClass);
}

function ChoosePawnSettings()
{
	if(!RegicidePRI(PlayerReplicationInfo).bCurrentlyKing)
	{
		super.ChoosePawnSettings();
	}
	else
	{		
		myPawnClass = RegicidePRI(PlayerReplicationInfo).CurrentKingFamily;
		
		if(AOCFamilyInfo_Agatha_King(RegicidePRI(PlayerReplicationInfo).CurrentKingFamily) != none)
		{
			myPrimaryWeapon = class'AOCWeapon_DoubleAxe';
			myAltPrimaryWeapon = class'AOCWeapon_DoubleAxe';
			mySecondaryWeapon = class'AOCWeapon_Longsword';
			myTertiaryWeapon = class'AOCWeapon_WarAxe';
		}
		else
		{
			myPrimaryWeapon = class'AOCWeapon_Messer';
			myAltPrimaryWeapon = class'AOCWeapon_Messer';
			mySecondaryWeapon = class'AOCWeapon_Maul';
			myTertiaryWeapon = class'AOCWeapon_MorningStar';
		}		
	}
}

function ApplyPawnSettings()
{
	local int TeamID;
	
	super.ApplyPawnSettings();
	if(RegicidePRI(PlayerReplicationInfo).bCurrentlyKing)
	{		
		TeamID = AOCPRI(PlayerReplicationInfo).GetCustomizationFactionFromActualFaction(RegicidePRI(PlayerReplicationInfo).CurrentKingFamily.FamilyFaction);

		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor1 = CustomizationClass.static.GetDefaultTabardColorIndex(0, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor2 = CustomizationClass.static.GetDefaultTabardColorIndex(1, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.TabardColor3 = CustomizationClass.static.GetDefaultTabardColorIndex(2, TeamID);

		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor1 = CustomizationClass.static.GetDefaultEmblemColorIndex(0, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor2 = CustomizationClass.static.GetDefaultEmblemColorIndex(1, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.EmblemColor3 = CustomizationClass.static.GetDefaultEmblemColorIndex(2, TeamID);

		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor1 = CustomizationClass.static.GetDefaultShieldColorIndex(0, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor2 = CustomizationClass.static.GetDefaultShieldColorIndex(1, TeamID);
		AOCPawn(Pawn).PawnInfo.myCustomization.ShieldColor3 = CustomizationClass.static.GetDefaultShieldColorIndex(2, TeamID);
	}
}