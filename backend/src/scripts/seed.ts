import mongoose from 'mongoose';
import dotenv from 'dotenv';
import Project from '../models/Project';
import CostConfig from '../models/CostConfig';
import Quote from '../models/Quote';
import Role from '../models/Role';
import User from '../models/User';
import bcrypt from 'bcryptjs';
import logger from '../utils/logger';

dotenv.config();

const seedRoles = async () => {
    const roles = [
        { name: 'admin', display_name: 'Administrator' },
        { name: 'designer', display_name: 'Interior Designer' },
        { name: 'assistant', display_name: 'Assistant Designer' },
        { name: 'client', display_name: 'Client' },
        { name: 'viewer', display_name: 'Viewer' },
    ];

    for (const role of roles) {
        await Role.findOne({ name: role.name }).then(async (existingRole) => {
            if (!existingRole) {
                await Role.create(role);
                logger.info(`Role ${role.name} created`);
            }
        });
    }
    logger.info('Roles Seeding Check Completed');
};

const seedSuperAdmin = async () => {
    const adminRole = await Role.findOne({ name: 'admin' });
    if (!adminRole) {
        logger.error('Admin role not found, cannot seed Super Admin');
        return;
    }

    const superAdminEmail = 'admin@example.com';
    const existingAdmin = await User.findOne({ email: superAdminEmail });

    if (!existingAdmin) {
        const hashedPassword = await bcrypt.hash('password123', 10);
        await User.create({
            role_id: adminRole._id,
            full_name: 'Super Admin',
            email: superAdminEmail,
            phone: '1234567890',
            password: hashedPassword,
            subscription: 'enterprise',
        });
        logger.info(`Super Admin created: ${superAdminEmail}`);
    } else {
        logger.info('Super Admin already exists');
    }
};

const seedData = async () => {
  try {
    await mongoose.connect(process.env.MONGO_URI || 'mongodb://localhost:27017/interior-design-db');
    logger.info('MongoDB Connected for Seeding');

    // Seed Roles and Super Admin
    await seedRoles();
    await seedSuperAdmin();

    // Clear existing data (Be careful with this if we want to preserve other data, but for this specific request regarding Projects/etc, leaving it as per original file or modifying? 
    // The prompt asked for specific role/user behavior. The original file cleared Projects/CostConfigs/Quotes. I'll preserve that behavior for those collections but NOT for Roles/Users which I handled above.)
    
    // Check if we should clear other data. If this script is run often, we might want to keep it. 
    // For now I'll keep the Original logic for other collections but I won't delete Roles/Users here.
    
    await Project.deleteMany({});
    await CostConfig.deleteMany({});
    await Quote.deleteMany({});

    // Seed Cost Configs
    const costConfigs = await CostConfig.create([
      { category: 'Flooring', itemType: 'Hardwood Oak', basePrice: 120, unit: 'sqft', laborCostPerUnit: 40 },
      { category: 'Flooring', itemType: 'Ceramic Tile', basePrice: 80, unit: 'sqft', laborCostPerUnit: 35 },
      { category: 'Wall', itemType: 'Premium Paint', basePrice: 45, unit: 'sqft', laborCostPerUnit: 15 },
      { category: 'Wall', itemType: 'Wallpaper', basePrice: 60, unit: 'sqft', laborCostPerUnit: 25 },
    ]);

    logger.info('Cost Configs Seeded');

    // Seed Projects
    const project = await Project.create({
      title: 'Modern Living Room Renovation',
      clientName: 'Alice Johnson',
      clientEmail: 'alice@example.com',
      requirements: {
        roomType: 'Living Room',
        style: 'Modern',
        budget: 15000,
      },
      status: 'pending_approval',
    });

    logger.info('Projects Seeded');

    // Seed Quote
    await Quote.create({
      project: project._id as any,
      items: [
        {
          name: 'Hardwood Oak Flooring',
          category: 'Flooring',
          quantity: 200,
          unitPrice: 160, // base + labor
          totalPrice: 32000,
        },
      ],
      totalAmount: 32000,
      status: 'draft',
    });

    logger.info('Quotes Seeded');

    logger.info('Data Seeding Completed Successfully');
    process.exit(0);
  } catch (error) {
    logger.error(`Error Seeding Data: ${error}`);
    process.exit(1);
  }
};

seedData();
