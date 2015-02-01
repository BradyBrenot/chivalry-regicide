class RegicidePlayerController extends AOCTDPlayerController;
	
reliable client function ClientOnFirstSpawn()
{
	ReceiveChatMessage("",Localize("Regicide", "WelcomeChatText", "Regicide"),EFAC_ALL,false,false,,false);
}
	
reliable client function ShowDefaultGameHeader()
{
	if (AOCGRI(Worldinfo.GRI) == none)
	{
		SetTimer(0.1f, false, 'ShowDefaultGameHeader');
		return;
	}	

	ClientShowLocalizedHeaderText(Localize("Regicide","SpawnHeader","Regicide"),,Localize("Regicide","SpawnSubHeader","Regicide"),true,true);
}

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
	
	ClientShowLocalizedHeaderText(Localize("Regicide","ChosenAsKingHeader","Regicide"),,Localize("Regicide","ChosenAsKingSubHeader","Regicide"),true,true);
}

reliable client function NotifyKingKilled(EAOCFaction KingFaction, PlayerReplicationInfo OldKing, PlayerReplicationInfo NewKing)
{
	//Woe!
	ReceiveChatMessage("",
		Repl(
			Repl(
				Repl(Localize("Regicide", "KingHasDied", "Regicide"), "{OLDKING}", OldKing.GetPlayerNameForMarkup()),
				"{NEWKING}", NewKing.GetPlayerNameForMarkup()),
			"{FACTION}", Localize("Common", KingFaction == EFAC_Agatha ? "AgathaKnights" : "MasonOrder", "AOCUI"))
		,EFAC_ALL,false,false,,false);
}

function ChangeToNewClass()
{
	local int TeamID;
	if(!RegicidePRI(PlayerReplicationInfo).bCurrentlyKing)
	{
		super.ChangeToNewClass();
	}
	else
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

		//Drops
		AOCPawn(Pawn).PawnInfo.myCustomization.Helmet = 0;
		AOCPawn(Pawn).PawnInfo.myCustomization.PrimaryWeaponDrop = 0;
		AOCPawn(Pawn).PawnInfo.myCustomization.SecondaryWeaponDrop = 0;
		AOCPawn(Pawn).PawnInfo.myCustomization.TertiaryWeaponDrop = 0;
	
		AOCPawn(Pawn).PawnInfo.myFamily = RegicidePRI(PlayerReplicationInfo).CurrentKingFamily;
		if(AOCFamilyInfo_Agatha_King(RegicidePRI(PlayerReplicationInfo).CurrentKingFamily) != none)
		{
			AOCPawn(Pawn).PawnInfo.myPrimary = class'AOCWeapon_DoubleAxe';
			AOCPawn(Pawn).PawnInfo.myAlternatePrimary = class'AOCWeapon_DoubleAxe';
			AOCPawn(Pawn).PawnInfo.mySecondary = class'AOCWeapon_Longsword';
			AOCPawn(Pawn).PawnInfo.myTertiary = class'AOCWeapon_WarAxe';
		}
		else
		{
			AOCPawn(Pawn).PawnInfo.myPrimary = class'AOCWeapon_Messer';
			AOCPawn(Pawn).PawnInfo.myAlternatePrimary = class'AOCWeapon_Messer';
			AOCPawn(Pawn).PawnInfo.mySecondary = class'AOCWeapon_Maul';
			AOCPawn(Pawn).PawnInfo.myTertiary = class'AOCWeapon_MorningStar';
		}

		AOCPRI(Pawn.PlayerReplicationInfo).MyFamilyInfo = RegicidePRI(PlayerReplicationInfo).CurrentKingFamily;

		AOCPawn(Pawn).ReplicatedEvent('PawnInfo');
	}
}


function PawnDied(Pawn P)
{
	super.PawnDied(P);
	/*if(AOCRegicidePawn(P).IsAKing())
	{
		bCurrentlyKing = false;
		CurrentKingFamily = none;
	}*/
}