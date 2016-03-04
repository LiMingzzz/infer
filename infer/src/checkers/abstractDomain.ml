(*
 * Copyright (c) 2016 - present Facebook, Inc.
 * All rights reserved.
 *
 * This source code is licensed under the BSD style license found in the
 * LICENSE file in the root directory of this source tree. An additional grant
 * of patent rights can be found in the PATENTS file in the same directory.
 *)

module F = Format

module type AbstractDomain = sig
  type astate

  val init : astate (* the initial state *)
  val bot : astate
  val is_bot : astate -> bool
  val lteq : astate -> astate -> bool (* fst \sqsubseteq snd? *)
  val join : astate -> astate -> astate
  val widen : astate -> astate -> astate
  val pp : F.formatter -> astate -> unit

end

module BotLiftedAbstractDomain (A : AbstractDomain) = struct
  type astate =
    | Bot
    | NonBot of A.astate

  let bot = Bot

  let is_bot astate =
    astate = Bot

  let init = NonBot A.init

  let lteq astate1 astate2 = match astate1, astate2 with
    | Bot, _ -> true
    | _ , Bot -> false
    | NonBot a1, NonBot a2 -> A.lteq a1 a2

  let join astate1 astate2 =
    match astate1, astate2 with
    | Bot, _ -> astate2
    | _, Bot -> astate1
    | NonBot a1, NonBot a2 -> NonBot (A.join a1 a2)

  let widen astate1 astate2 =
    match astate1, astate2 with
    | Bot, _ -> astate2
    | _, Bot -> astate1
    | NonBot a1, NonBot a2 -> NonBot (A.widen a1 a2)

  let pp fmt = function
    | Bot -> F.fprintf fmt "_|_"
    | NonBot astate -> A.pp fmt astate

end