//==============================================
// Weapons and functions for the PLASMA class and
// associated weaponry
//==============================================

void () TeleGrenadeTouch;
void () plasma_touch;

void () plasmaRocket_touch = {
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
    damg = 40;
    deathmsg = self.weapon;

    if (other.health) {
        TF_T_Damage(other, self, self.owner, damg, TF_TD_NOTTEAM,
                    TF_TD_ELECTRICITY);
    }

    T_RadiusDamage(self, self.owner, damg, other);

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_TAREXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);
    multicast(self.origin, MULTICAST_PHS);

    dremove(self);
};

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

void () W_FirePlasmaRocket = {

    if (self.ammo_rockets < 1) {
        W_ChangeToBestWeapon();
        return;
    }

    self.ammo_rockets = self.ammo_rockets - 1;
    self.currentammo = self.ammo_rockets;
    sound(self, CHAN_WEAPON, "weapons/sgun1.wav", 1, ATTN_NORM);

    newmis = spawn();
    newmis.owner = self;
    newmis.movetype = MOVETYPE_FLYMISSILE;
    newmis.solid = SOLID_BBOX;

    makevectors(self.v_angle);
    newmis.velocity = v_forward;
    newmis.velocity = newmis.velocity * 1500;
    newmis.angles = vectoangles(newmis.velocity);

    newmis.touch = plasmaRocket_touch;
    newmis.voided = 0;

    newmis.nextthink = time + 2;
    newmis.think = SUB_Remove;

    newmis.weapon = DMSG_ROCKETL;
    newmis.classname = "plasmarocket";
    setmodel(newmis, "progs/plasma.mdl");
    setsize(newmis, '0 0 0', '0 0 0');
    setorigin(newmis, self.origin + v_forward * 8 + '0 0 16');

    KickPlayer(-3, self);
};



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

void () W_Reload_plasma = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_plasma.mdl";
    sprint(self.owner, PRINT_LOW, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void () W_Reload_plasmaRocket = {
    self.owner.tfstate = self.owner.tfstate - (self.owner.tfstate & TFSTATE_RELOADING);
    self.owner.weaponmodel = "progs/v_irock.mdl";
    sprint(self.owner, PRINT_LOW, "Finished reloading\n");
    dremove(self);
    W_WeaponState_Load(self.owner, 0);
    Status_Refresh(self.owner);
};

void () TeamFortress_PlasmaRocket = {
    if (!(self.weapons_carried & WEAP_PLASMAROCKET)) {
        return;
    }
    if (self.ammo_rockets < 1) {
        sprint(self, PRINT_HIGH, "Not enough ammo\n");
        return;
    }
    self.current_weapon = WEAP_PLASMAROCKET;
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

    if (trace_startsolid != 1) {
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

vector (vector org, float positive, float units, string axis) TestTeleDir = {
    float dist;
    vector modorg;
    dist = 0;
    modorg = org;

    if (positive != 1) {
        // it's 0 for negative
        positive = -1;
    }
    switch (axis) {
        case "x":
            modorg_x += units * positive;
            break;
        case "y":
            modorg_y += units * positive;
            break;
        case "z":
            modorg_z += units * positive;
    }

    traceline(org, modorg, MOVE_NOMONSTERS, self.owner);

    // didn't go whole way, so work out how far to modify vector
    if (trace_fraction != 1) {
        dist = floor(units * trace_fraction);
        dist = units - dist;
        switch (axis) {
        case "x":
            org_x -= dist * positive;
            break;
        case "y":
            org_y -= dist * positive;
            break;
        case "z":
            org_z -= dist * positive;
        }
    }
    return org;
}

void () TeleGrenadeExplode = {
    if (self.lifenum == self.owner.lifenum) {
        vector org, modorg;
        float theight = 25;
        float twide = 20;
        float test;

        org = self.origin;
        modorg = org;
        test = 0;
        // put player feet at grenade level
        modorg_z += theight;
        test = TestTeleLoc(modorg);

        if (test == 0) {
            // test if on an angled floor
            traceline(modorg, mordorg - '0 0 50', MOVE_NOMONSTERS, self.owner);
            if (trace_fraction != 1) {
                vector ang = self.angles;
                ang_x *= -1;
                makevectors(ang);
                vector coplanar = v_forward-(v_forward*trace_plane_normal)*trace_plane_normal;
                // pitch, yaw, 0
                vector angles = vectoangles(coplanar, trace_plane_normal);
                dprint(strcat("angles: ", vtos(angles)));

                // modify modorg appropriately
            }

            modorg = TestTeleDir(modorg, 1, theight, "z");
            modorg = TestTeleDir(modorg, 0, theight, "z");
            modorg = TestTeleDir(modorg, 1, twide, "y");
            modorg = TestTeleDir(modorg, 0, twide, "y");
            modorg = TestTeleDir(modorg, 1, twide, "x");
            modorg = TestTeleDir(modorg, 0, twide, "x");

            test = TestTeleLoc(modorg);
        }
        
        if (test == 1) {
            PerformTele(self.owner, modorg);
        } /*else {
            dprint("no good tele point found\n");
            // could kill player here but would be unfun
        }*/
    }

    WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
    WriteByte(MSG_MULTICAST, TE_EXPLOSION);
    WriteCoord(MSG_MULTICAST, self.origin_x);
    WriteCoord(MSG_MULTICAST, self.origin_y);
    WriteCoord(MSG_MULTICAST, self.origin_z);

    multicast(self.origin, MULTICAST_PHS);
    dremove(self);
};