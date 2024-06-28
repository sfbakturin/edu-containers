#include <gtest/gtest.h>

#include <stdexcept>

static void throwing_func()
{
	throw std::logic_error("no escape");
}

TEST(basic_test, throwing)
{
	EXPECT_THROW(throwing_func(), std::logic_error);
}

TEST(basic_test, a_plus_b)
{
	EXPECT_EQ(1 + 2, 2 + 1);
	EXPECT_EQ(1 + 0, 0 + 1);
}

int main(int argc, char **argv)
{
	::testing::InitGoogleTest(&argc, argv);
	return RUN_ALL_TESTS();
}
