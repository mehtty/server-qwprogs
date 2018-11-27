//==============================================
// Weapons and functions for the PLASMA class and
// associated weaponry
//==============================================

void () TeleGrenadeTouch;
void () plasma_touch;

void (vector org, vector dir) launch_plasma = {
    newmis = spawn();
    newmis.voided = 0;
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;

    newmis.angles = vectoangles(dir);
    newmis.touch = plasma_touch;
    newmis.weapon = DMSG_PLASMA;
    newmis.classname = "plasma";
    newmis.think = SUB_Remove;
    newmis.nextthink = time + 6;
    setmodel(newmis, "progs/plasma.mdl");
    setsize(newmis, VEC_ORIGIN, VEC_ORIGIN);
    setorigin(newmis, org);

    newmis.velocity = dir * 1500;
};

void () W_FirePlasma = {

    if (self.ammo_cells < 1) {
        W_ChangeToBestWeapon();
        return;
    }

    local vector dir;

    makevectors(self.v_angle);
    sound(self, CHAN_WEAPON, "weapons/plasma.wav", 1, ATTN_NORM);

    self.ammo_cells = self.ammo_cells - 1;
    self.currentammo = self.ammo_cells;
    dir = aim(self, 1000);
    launch_plasma(self.origin + '0 0 16', dir);
    KickPlayer(-3, self);
};

void () W_FireAirGun = {

    KickPlayer(-3, self);
};

.float hit_z;

void () plasma_touch = {
    if (self.voided)
        return;
    self.voided = 1;

    if (other.solid == SOLID_TRIGGER)
        return;

    if (pointcontents(self.origin) == CONTENT_SKY) {
        dremove(self);
        return;
    }
    float damg;
    damg = 20;
    deathmsg = self.weapon;

    if (other.health) {
        TF_T_Damage(other, self, self.owner, damg, TF_TD_NOTTEAM,
                    TF_TD_ELECTRICITY);
    }

    T_RadiusDamage(self, self.owner, damg, other);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_SPIKE);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    dremove(self);
};

void () TeamFortress_Plasma = {
    if (!(self.weapons_carried & WEAP_PLASMA)) {
        return;
    }
    if (self.ammo_cells < 1) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }
    self.current_weapon = WEAP_PLASMA;
    W_SetCurrentAmmo(self);
};

void () TeamFortress_AirGun = {
    if (!(self.weapons_carried & WEAP_AIRGUN)) {
        return;
    }
    if (self.ammo_rockets < 1) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }
    self.current_weapon = WEAP_AIRGUN;
    W_SetCurrentAmmo(self);
};

void () TeleGrenadeTouch = {
    sound(self, CHAN_WEAPON, "weapons/bounce.wav", 1, ATTN_NORM);
    if (self.velocity == '0 0 0')
        self.avelocity = '0 0 0';
};

float (vector org) TestTeleLoc = {
    float t;
    t = 0;
    tracebox(org, self.owner.mins, self.owner.maxs, org, MOVE_NOMONSTERS, self.owner);

    if (trace_startsolid == 1) {
        t = 0;
    } else {
        t = trace_fraction;
    }

    return t;
}

void (entity player, vector dest) PerformTele = {
    // put a tfog where the player was
    spawn_tfog(player.origin);

    // spawn a tfog flash at the destination
    spawn_tfog(dest);

    setorigin(player, dest);

    spawn_tdeath(dest, player);
}

void () TeleGrenadeExplode = {
    deathmsg = DMSG_GREN_TELE;

    vector org, modorg;
    float xloop, test, yloop, zloop;
    org = self.origin;
    test = 0;
    
    if (self.flags && FL_ONGROUND) {
        org = org + '0 0 25';
    }
    modorg = org;
    test = TestTeleLoc(modorg);

    if (test == 0) {
        // loop through 30x30x50 unit box to test for tele position
        // i refuse to use a goto and i'm not restructuring this in to a function with return value so lots of breaks

        for (xloop = -30; xloop <= 30; xloop += 10) {
            modorg = org;
            modorg_x += xloop;
            test = TestTeleLoc(modorg);
            if (test == 1) {
                break;
            }

            for (yloop = -30; yloop <= 30; yloop += 10) {
                modorg_y += yloop;
                test = TestTeleLoc(modorg);
                if (test == 1) {
                    break;
                }

                for (zloop = -50; zloop <= 50; zloop += 10) {
                    modorg_z += zloop;
                    test = TestTeleLoc(modorg);
                    if (test == 1) {
                        break;
                    }
                }

                if (test == 1) {
                    break;
                }
            }

            if (test == 1) {
                break;
            }
        }
    }
    
    if (test == 1) {
        PerformTele(self.owner, modorg);
    }

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);

    multicast(self.origin, MULTICAST_PHS);
    dremove(self);
};