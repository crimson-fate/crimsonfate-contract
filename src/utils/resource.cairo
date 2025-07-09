use crimson_fate::models::resource::ResourceType;
use core::panic_with_felt252;

pub fn get_resource_type(resource: u8) -> ResourceType {
    match resource {
        0 => ResourceType::Mechanic,
        1 => ResourceType::Fire,
        2 => ResourceType::Lightning,
        3 => ResourceType::Mythic,
        4 => ResourceType::Pollute,
        5 => ResourceType::Five_Element,
        _ => panic_with_felt252('resource not found')
    }
}
