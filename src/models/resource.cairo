use starknet::ContractAddress;

#[derive(Drop, Serde)]
#[dojo::model]
pub struct PlayerSoulPieceResource {
    #[key]
    pub player: ContractAddress,
    pub mechanic_soul: u128,
    pub fire_soul: u128,
    pub lightning_soul: u128,
    pub mythic_soul: u128,
    pub pollute_soul: u128,
}

#[derive(Drop, Serde, Copy)]
pub enum ResourceType {
    Mechanic,
    Fire,
    Lightning,
    Mythic,
    Pollute,
    Five_Element,
}

impl IntoResourceType of Into<ResourceType, felt252> {
    fn into(self: ResourceType) -> felt252 {
        match self {
            ResourceType::Mechanic => 'Mechanic',
            ResourceType::Fire => 'Fire',
            ResourceType::Lightning => 'Lightning',
            ResourceType::Mythic => 'Mythic',
            ResourceType::Pollute => 'Pollute',
            ResourceType::Five_Element => 'Five_Element',
        }
    }
}

impl PartialEqResourceType of PartialEq<ResourceType> {
    fn eq(lhs: @ResourceType, rhs: @ResourceType) -> bool {
        match (*lhs).into() - (*rhs).into() {
            0 => true,
            _ => false,
        }
    }

    fn ne(lhs: @ResourceType, rhs: @ResourceType) -> bool {
        match (*lhs).into() - (*rhs).into() {
            0 => false,
            _ => true,
        }
    }
}
