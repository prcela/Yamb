//
//  MessageFunc.swift
//  Yamb
//
//  Created by Kresimir Prcela on 10/09/16.
//  Copyright © 2016 100kas. All rights reserved.
//

import Foundation

enum MessageFunc: String
{
    case Join = "join"
    case Disconnected = "disconnected"
    case Match = "match"
    case Message = "message"
    case RoomInfo = "room_info"
    case CreateMatch = "create_match"
    case JoinMatch = "join_match"
    case LeaveMatch = "leave_match"
    case Turn = "turn"
    case InvitePlayer = "invite_player"
    case IgnoreInvitation = "ignore_invitation"
    case TextMessage = "text_message"
    case UpdatePlayer = "update_player"
}
