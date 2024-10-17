import os, aiohttp, asyncio
from aiogram import Bot, Dispatcher
from aiogram.filters import CommandStart
from dotenv import load_dotenv

load_dotenv()
BOT_TOKEN = os.getenv("BOT_TOKEN")
CHAT_ID = os.getenv("CHAT_ID")
THREAD_ID = os.getenv("THREAD_ID")
ITEM_ID = os.getenv("ITEM_ID")
for i in ["BOT_TOKEN", "CHAT_ID", "THREAD_ID", "ITEM_ID"]:
    if not globals()[i]:
        raise Exception(f"Не задан {i}")

bot = Bot(token=BOT_TOKEN)
dp = Dispatcher()


async def get_items() -> list:
    try:
        async with aiohttp.ClientSession("https://api.sandbox.game") as session:
            async with session.get(f"/nftorders/asset/{ITEM_ID}") as response:
                return await response.json()
    except:
        return []


async def get_item() -> dict | None:
    try:
        items = await get_items()
        if len(items) == 0:
            return None
        items.sort(key=lambda x: float(x["price"]))
        items = list(filter(lambda x: x["availableListings"] > 0, items))
        return items[0]
    except:
        return None


async def send_alert(price: float, availability: int):
    await bot.send_message(
        CHAT_ID,
        f"🔥 Availability: {availability}\n"
        + f"💲 Price: {price}\n"
        + f"<a href='https://www.sandbox.game/en/assets/season-4-alpha-pass/{ITEM_ID}'>💸 Buy</a>",
        parse_mode="HTML",
        message_thread_id=THREAD_ID,
        disable_web_page_preview=True,
    )


@dp.message(CommandStart())
async def start(_):
    prev_price, prev_availability = None, None

    while True:
        item = await get_item()
        if item is None:
            await asyncio.sleep(5)
            continue

        price = round(float(item["price"]), 1)
        availability = int(item["availableListings"])
        if prev_price is None and prev_availability is None:
            prev_price, prev_availability = price, availability
            continue

        if price < prev_price or (
            price == prev_price and availability > prev_availability
        ):
            await send_alert(price, availability)
            prev_price, prev_availability = price, availability

        await asyncio.sleep(5)

async def main():
    bot_name = await bot.get_me()
    print(
        f"Notifier запущен, напишите команду /start боту @{bot_name.username}"
    )
    await dp.start_polling(bot)


if __name__ == "__main__":
    asyncio.run(main())
