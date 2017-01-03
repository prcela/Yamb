//
//  NotificationName.swift
//  Yamb
//
//  Created by Kresimir Prcela on 20/08/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

extension NSNotification.Name
{
    static let matchStateChanged = NSNotification.Name("Notification.GameStateChanged")
    static let authenticatedLocalPlayer = NSNotification.Name("Notification.AuthenticatedLocalPlayer")
    static let goToMainMenu = NSNotification.Name("Notification.goToMainMenu")
    static let goToMainRoom = NSNotification.Name("Notification.goToMainRoom")
    static let alertForInput = NSNotification.Name("Notification.alertForInput")
    static let onRoomInfo = NSNotification.Name("Notification.onRoomInfo")
    static let joinedMatch = NSNotification.Name("Notification.joinedMatch")
    static let maybeSomeoneWillDump = NSNotification.Name("Notification.maybeSomeoneWillDump")
    static let dumped = NSNotification.Name("Notification.dumped")
    static let opponentLeavedMatch = NSNotification.Name("Notification.opponentLeavedMatch")
    static let opponentNewGame = NSNotification.Name("Notification.opponentNewGame")
    static let matchInvitationArrived = NSNotification.Name("Notification.matchInvitationArrived")
    static let matchInvitationIgnored = NSNotification.Name("Notification.matchInvitationIgnored")
    static let matchReceivedTextMessage = NSNotification.Name("Notification.matchReceivedTextMessage")
    static let wsConnect = NSNotification.Name("Notification.wsConnect")
    static let wsDidConnect = NSNotification.Name("Notification.wsDidConnect")
    static let wsDidDisconnect = NSNotification.Name("Notification.DidDisconnect")
    static let playerDiamondsChanged = NSNotification.Name("Notification.playerDiamondsChanged")
    static let playerStatItemsChanged = NSNotification.Name("Notification.playerStatItemsChanged")
    static let playerFavDiceChanged = NSNotification.Name("Notification.playerFavDiceChanged")
    static let playerAliasChanged = NSNotification.Name("Notification.playerAliasChanged")
    static let multiplayerMatchEnded = NSNotification.Name("Notification.multiplayerMatchEnded")
    static let containerItemSelected = NSNotification.Name("Notification.containerItemSelected")
    static let onPlayerTurnInMultiplayer = NSNotification.Name("Notification.onPlayerTurnInMultiplayer")
    static let wantsUnownedDiceMaterial = NSNotification.Name("Notification.wantsUnownedDiceMaterial")
}
