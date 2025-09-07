import { describe, it, expect, beforeEach } from "vitest";

const ERR_NOT_AUTHORIZED = 100;
const ERR_INVALID_GOAL = 101;
const ERR_INVALID_DEADLINE = 102;
const ERR_INVALID_TITLE = 103;
const ERR_INVALID_DESCRIPTION = 104;
const ERR_CAMPAIGN_ALREADY_EXISTS = 105;
const ERR_CAMPAIGN_NOT_FOUND = 106;
const ERR_CAMPAIGN_CLOSED = 107;
const ERR_DEADLINE_PASSED = 108;
const ERR_INVALID_MIN_DONATION = 109;
const ERR_INVALID_TOKEN_TYPE = 110;
const ERR_MAX_CAMPAIGNS_EXCEEDED = 111;
const ERR_INVALID_UPDATE_GOAL = 112;
const ERR_UPDATE_NOT_ALLOWED = 113;
const ERR_INVALID_CATEGORY = 114;
const ERR_INVALID_STATUS = 115;
const ERR_INVALID_START_TIME = 116;
const ERR_INVALID_MILESTONES = 117;
const ERR_INVALID_REFUND_POLICY = 118;
const ERR_INVALID_KYC_REQUIRED = 119;
const ERR_INVALID_MAX_DONORS = 120;
const ERR_INVALID_LOCATION = 121;
const ERR_INVALID_TAGS = 122;
const ERR_INVALID_IMAGE_HASH = 123;
const ERR_INVALID_VIDEO_HASH = 124;
const ERR_INVALID_WEBSITE = 125;
const ERR_INVALID_EMAIL = 126;
const ERR_INVALID_PHONE = 127;
const ERR_INVALID_SOCIAL_LINKS = 128;
const ERR_INVALID_TEAM_MEMBERS = 129;
const ERR_INVALID_BUDGET_BREAKDOWN = 130;

interface Campaign {
  goal: number;
  raised: number;
  deadline: number;
  startTime: number;
  active: boolean;
  creator: string;
  title: string;
  description: string;
  minDonation: number;
  tokenType: string;
  category: string;
  status: string;
  milestones: number[];
  refundPolicy: boolean;
  kycRequired: boolean;
  maxDonors: number;
  location: string;
  tags: string[];
  imageHash: string;
  videoHash: string;
  website: string;
  email: string;
  phone: string;
  socialLinks: string[];
  teamMembers: string[];
  budgetBreakdown: string;
}

interface CampaignUpdate {
  updateGoal: number;
  updateDeadline: number;
  updateDescription: string;
  updateTimestamp: number;
  updater: string;
}

class CampaignInstanceMock {
  state!: {
    nextCampaignId: number;
    maxCampaigns: number;
    campaigns: Map<number, Campaign>;
    campaignsByCreator: Map<string, number[]>;
    campaignUpdates: Map<number, CampaignUpdate>;
  };
  blockHeight = 0;
  caller = "ST1TEST";
  governance = null as string | null;

  constructor() {
    this.reset();
  }
  reset() {
    this.state = {
      nextCampaignId: 0,
      maxCampaigns: 10000,
      campaigns: new Map(),
      campaignsByCreator: new Map(),
      campaignUpdates: new Map(),
    };
    this.blockHeight = 0;
    this.caller = "ST1TEST";
    this.governance = null;
  }

  createCampaign(
    goal: number,
    deadline: number,
    title: string,
    description: string,
    minDonation: number,
    tokenType: string,
    category: string,
    milestones: number[],
    refundPolicy: boolean,
    kycRequired: boolean,
    maxDonors: number,
    location: string,
    tags: string[],
    imageHash: string,
    videoHash: string,
    website: string,
    email: string,
    phone: string,
    socialLinks: string[],
    teamMembers: string[],
    budgetBreakdown: string
  ) {
    const nextId = this.state.nextCampaignId;
    if (nextId >= this.state.maxCampaigns) return { ok: false, value: ERR_MAX_CAMPAIGNS_EXCEEDED };
    if (goal <= 0) return { ok: false, value: ERR_INVALID_GOAL };
    if (deadline <= this.blockHeight) return { ok: false, value: ERR_INVALID_DEADLINE };
    if (!title || title.length > 100) return { ok: false, value: ERR_INVALID_TITLE };
    if (!description || description.length > 1000) return { ok: false, value: ERR_INVALID_DESCRIPTION };
    if (minDonation < 0) return { ok: false, value: ERR_INVALID_MIN_DONATION };
    if (!["STX", "SIP10"].includes(tokenType)) return { ok: false, value: ERR_INVALID_TOKEN_TYPE };
    if (!category || category.length > 50) return { ok: false, value: ERR_INVALID_CATEGORY };
    if (imageHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(imageHash)) return { ok: false, value: ERR_INVALID_IMAGE_HASH };
    if (videoHash.length !== 64 || !/^[0-9a-fA-F]+$/.test(videoHash)) return { ok: false, value: ERR_INVALID_VIDEO_HASH };

    const newCampaign: Campaign = {
      goal,
      raised: 0,
      deadline,
      startTime: this.blockHeight,
      active: true,
      creator: this.caller,
      title,
      description,
      minDonation,
      tokenType,
      category,
      status: "active",
      milestones,
      refundPolicy,
      kycRequired,
      maxDonors,
      location,
      tags,
      imageHash,
      videoHash,
      website,
      email,
      phone,
      socialLinks,
      teamMembers,
      budgetBreakdown,
    };
    this.state.campaigns.set(nextId, newCampaign);
    const creatorCampaigns = this.state.campaignsByCreator.get(this.caller) || [];
    this.state.campaignsByCreator.set(this.caller, [...creatorCampaigns, nextId]);
    this.state.nextCampaignId++;
    return { ok: true, value: nextId };
  }

  getCampaign(id: number) {
    const campaign = this.state.campaigns.get(id);
    return campaign ? { ok: true, value: campaign } : { ok: false, value: null };
  }

  updateCampaign(id: number, newGoal: number, newDeadline: number, newDescription: string) {
    const campaign = this.state.campaigns.get(id);
    if (!campaign) return { ok: false, value: ERR_CAMPAIGN_NOT_FOUND };
    if (campaign.creator !== this.caller) return { ok: false, value: ERR_NOT_AUTHORIZED };
    if (!campaign.active) return { ok: false, value: ERR_CAMPAIGN_CLOSED };
    if (newGoal <= 0) return { ok: false, value: ERR_INVALID_GOAL };
    if (newDeadline <= this.blockHeight) return { ok: false, value: ERR_INVALID_DEADLINE };
    if (!newDescription || newDescription.length > 1000) return { ok: false, value: ERR_INVALID_DESCRIPTION };

    const updated: Campaign = { ...campaign, goal: newGoal, deadline: newDeadline, description: newDescription };
    this.state.campaigns.set(id, updated);
    this.state.campaignUpdates.set(id, {
      updateGoal: newGoal,
      updateDeadline: newDeadline,
      updateDescription: newDescription,
      updateTimestamp: this.blockHeight,
      updater: this.caller,
    });
    return { ok: true, value: true };
  }

  closeCampaign(id: number) {
    const campaign = this.state.campaigns.get(id);
    if (!campaign) return { ok: false, value: ERR_CAMPAIGN_NOT_FOUND };
    if (campaign.creator !== this.caller) return { ok: false, value: ERR_NOT_AUTHORIZED };
    if (!campaign.active) return { ok: false, value: ERR_CAMPAIGN_CLOSED };

    const updated: Campaign = { ...campaign, active: false, status: "closed" };
    this.state.campaigns.set(id, updated);
    return { ok: true, value: true };
  }

  addRaised(id: number, amount: number) {
    const campaign = this.state.campaigns.get(id);
    if (!campaign) return { ok: false, value: ERR_CAMPAIGN_NOT_FOUND };
    if (this.governance === null) return { ok: false, value: ERR_NOT_AUTHORIZED };
    if (this.caller !== this.governance) return { ok: false, value: ERR_NOT_AUTHORIZED };
    if (!campaign.active) return { ok: false, value: ERR_CAMPAIGN_CLOSED };
    if (this.blockHeight >= campaign.deadline) return { ok: false, value: ERR_DEADLINE_PASSED };

    const updated: Campaign = { ...campaign, raised: campaign.raised + amount };
    this.state.campaigns.set(id, updated);
    return { ok: true, value: true };
  }
}

describe("CampaignInstance", () => {
  let contract: CampaignInstanceMock;
  beforeEach(() => (contract = new CampaignInstanceMock()));

  it("creates a valid campaign", () => {
    const result = contract.createCampaign(
      1000,
      100,
      "Test Campaign",
      "Description",
      10,
      "STX",
      "Charity",
      [100, 200],
      true,
      false,
      100,
      "Location",
      ["tag1", "tag2"],
      "a".repeat(64),
      "b".repeat(64),
      "https://example.com",
      "test@example.com",
      "1234567890",
      ["https://social1.com"],
      ["Member1"],
      "Budget details"
    );
    expect(result.ok).toBe(true);
    expect(contract.getCampaign(0).value?.title).toBe("Test Campaign");
  });

  it("rejects invalid goal", () => {
    const result = contract.createCampaign(
      0,
      100,
      "Title",
      "Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    expect(result).toEqual({ ok: false, value: ERR_INVALID_GOAL });
  });

  it("rejects invalid deadline", () => {
    contract.blockHeight = 50;
    const result = contract.createCampaign(
      1000,
      40,
      "Title",
      "Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    expect(result).toEqual({ ok: false, value: ERR_INVALID_DEADLINE });
  });

  it("rejects invalid token type", () => {
    const result = contract.createCampaign(
      1000,
      100,
      "Title",
      "Desc",
      10,
      "Invalid",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    expect(result).toEqual({ ok: false, value: ERR_INVALID_TOKEN_TYPE });
  });

  it("updates a valid campaign", () => {
    contract.createCampaign(
      1000,
      100,
      "Title",
      "Old Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    const res = contract.updateCampaign(0, 2000, 200, "New Desc");
    expect(res.ok).toBe(true);
    expect(contract.getCampaign(0).value?.description).toBe("New Desc");
  });

  it("rejects update for non-existent campaign", () => {
    const res = contract.updateCampaign(99, 2000, 200, "New");
    expect(res).toEqual({ ok: false, value: ERR_CAMPAIGN_NOT_FOUND });
  });

  it("closes a valid campaign", () => {
    contract.createCampaign(
      1000,
      100,
      "Title",
      "Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    const res = contract.closeCampaign(0);
    expect(res.ok).toBe(true);
    expect(contract.getCampaign(0).value?.active).toBe(false);
  });

  it("rejects close for non-existent campaign", () => {
    const res = contract.closeCampaign(99);
    expect(res).toEqual({ ok: false, value: ERR_CAMPAIGN_NOT_FOUND });
  });

  it("adds raised amount", () => {
    contract.createCampaign(
      1000,
      100,
      "Title",
      "Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    contract.governance = "ST1TEST";
    const res = contract.addRaised(0, 500);
    expect(res.ok).toBe(true);
    expect(contract.getCampaign(0).value?.raised).toBe(500);
  });

  it("rejects add raised without governance", () => {
    contract.createCampaign(
      1000,
      100,
      "Title",
      "Desc",
      10,
      "STX",
      "Cat",
      [],
      false,
      false,
      0,
      "",
      [],
      "a".repeat(64),
      "b".repeat(64),
      "",
      "",
      "",
      [],
      [],
      ""
    );
    const res = contract.addRaised(0, 500);
    expect(res).toEqual({ ok: false, value: ERR_NOT_AUTHORIZED });
  });
});