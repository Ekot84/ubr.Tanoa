// Arcade-style health regeneration
while { alive player } do {
    if (damage player > 0) then {
        player setDamage ((damage player) - 0.01); // Regenerate 1% health every 0.5 seconds
    };
    sleep 0.5;
};