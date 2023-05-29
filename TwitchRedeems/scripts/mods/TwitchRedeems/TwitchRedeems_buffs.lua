local mod = get_mod("TwitchRedeems")

-- Enemies spawned with Twitch redeems will have purple glowing eyes.
mod.add_buff_template("twitch_redeem_buff_eye_glow",
{
    remove_buff_func = "belakor_cultists_remove_eye_glow",
    name = "belakor_cultists_buff_eye_glow",
    apply_buff_func = "belakor_cultists_apply_eye_glow"
}, nil, 1900)

-- Makes enemies pingable.
mod.add_buff_template("twitch_redeem_buff_pingable",
{
    remove_buff_func = "remove_make_pingable",
    name = "twitch_redeem_buff_pingable",
    apply_buff_func = "apply_make_pingable"
}, nil, 1901)