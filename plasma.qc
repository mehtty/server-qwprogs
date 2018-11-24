//==============================================
// Weapons and functions for the PLASMA class and
// associated weaponry
//==============================================

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
    if (other.takedamage) {
        spawn_touchblood(20);
        deathmsg = self.weapon;
        TF_T_Damage(other, self, self.owner.owner, 20, TF_TD_NOTTEAM,
                    TF_TD_ELECTRICITY);
    } else {
        WriteByte(MSG_MULTICAST, SVC_TEMPENTITY);
        WriteByte(MSG_MULTICAST, TE_SPIKE);
        WriteCoord(MSG_MULTICAST, self.origin_x);
        WriteCoord(MSG_MULTICAST, self.origin_y);
        WriteCoord(MSG_MULTICAST, self.origin_z);
        multicast(self.origin, MULTICAST_PHS);
    }
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