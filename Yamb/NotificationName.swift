//
//  NotificationName.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

struct NotificationName
{
    static let matchStateChanged = "Notification.GameStateChanged"
    static let authenticatedLocalPlayer = "Notification.AuthenticatedLocalPlayer"
    static let goToMainMenu = "Notification.goToMainMenu"
    static let goToMainRoom = "Notification.goToMainRoom"
    static let alertForInput = "Notification.alertForInput"
    static let onRoomInfo = "Notification.onRoomInfo"
    static let joinedMatch = "Notification.joinedMatch"
    static let maybeSomeoneWillDump = "Notification.maybeSomeoneWillDump"
    static let dumped = "Notification.dumped"
    static let opponentLeavedMatch = "Notification.opponentLeavedMatch"
    static let opponentNewGame = "Notification.opponentNewGame"
    static let matchInvitationArrived = "Notification.matchInvitationArrived"
    static let matchInvitationIgnored = "Notification.matchInvitationIgnored"
    static let matchReceivedTextMessage = "Notification.matchReceivedTextMessage"
    static let wsConnect = "Notification.wsConnect"
    static let wsDidConnect = "Notification.wsDidConnect"
    static let wsDidDisconnect = "Notification.DidDisconnect"
    static let playerDiamondsChanged = "Notification.playerDiamondsChanged"
    static let playerStatItemsChanged = "Notification.playerStatItemsChanged"
    static let playerFavDiceChanged = "Notification.playerFavDiceChanged"
    static let playerAliasChanged = "Notification.playerAliasChanged"
    static let multiplayerMatchEnded = "Notification.multiplayerMatchEnded"
    static let containerItemSelected = "Notification.containerItemSelected"
    static let onPlayerTurnInMultiplayer = "Notification.onPlayerTurnInMultiplayer"
    static let wantsUnownedDiceMaterial = "Notification.wantsUnownedDiceMaterial"
}
